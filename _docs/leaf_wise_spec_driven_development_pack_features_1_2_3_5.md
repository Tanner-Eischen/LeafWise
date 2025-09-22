# LeafWise – Spec‑Driven Development Pack

> Objective: Ship four high‑impact features with minimal error‑surface via strict contracts, module boundaries, and executable‑spec style acceptance criteria. Targets map to the earlier roadmap items: **(1) On‑device AI & Offline Mode**, **(2) Context‑Aware Care Plans**, **(3) Sensor & Photo Telemetry**, **(5) Smart Community (RAG‑Grounded Answers)**.

---

## Global Conventions

**Language/Platform:** Mobile client may be Flutter or React Native; contracts are platform‑agnostic. Backend assumed FastAPI + PostgreSQL + Redis + S3 (or compatible).  
**Versioning:** All new endpoints under `/api/v1/…` with semantic versioning embedded via `x-api-version: 1`.  
**Auth:** Bearer JWT; refresh via existing token endpoint.  
**Idempotency:** All mutating endpoints accept `Idempotency-Key` header.  
**Time:** All timestamps ISO‑8601 UTC.  
**Errors:** RFC7807 problem+json with `type`, `title`, `detail`, `instance`, `code`.

**Feature flags** (server‑authored, client‑consumed):
- `ff.offline_ai` (1), `ff.care_plans_v2` (2), `ff.telemetry_v1` (3), `ff.community_rag_v1` (5)

**Observability:** Correlate with `X-Request-Id` (server) and `x-client-trace-id` (client). Emit metrics listed per feature.

---

## 1) On‑Device AI & Offline Mode

### 1.1 Goals
- Provide offline plant ID triage and cached embeddings to function without network.  
- Transparent sync when connectivity returns.  
- Preserve privacy; no PII in on‑device model IO.

### 1.2 Non‑Goals
- Full parity with server SOTA model.  
- Training on device.

### 1.3 User Stories
- *As a user*, with no signal, I can take a photo and receive a basic species guess with confidence bands within 2s.  
- *As a user*, my offline results auto‑sync to my history when I’m back online without duplicates.

### 1.4 Architecture Overview
- **Mobile**: `ai_local` module exposes: `infer(image) -> LocalPrediction`, `embed(image) -> float[dim]`, `cache.store/get`, `sync.queue`.  
- **Backend**: Accepts queued offline results for server reconciliation.

### 1.5 Data Contracts
**LocalPrediction (JSON, stored offline)**
```json
{
  "id": "ulid",
  "device_ts": "2025-09-05T19:00:00Z",
  "image_local_uri": "string",
  "topk": [
    {"label": "ficus_lyrata", "score": 0.74},
    {"label": "ficus_elastica", "score": 0.19}
  ],
  "embedding": "base64(float32[384])",
  "calib_version": "v1",
  "synced": false
}
```

### 1.6 Sync API
**POST** `/api/v1/offline/predictions:batch`  
Body:
```json
{
  "predictions": [ {"id": "01J…", "device_ts": "…", "embedding": "…", "topk": [ {"label": "…", "score": 0.74} ]} ],
  "client_model": {"name": "lw-lite", "version": "1.0.3"}
}
```
Responses: `207 Multi-Status` with per‑item `status` and `server_correction` if the server re‑scores.

### 1.7 Storage
- **Client**: encrypted KV (MMKV/SecureStorage) + small LRU for embeddings.  
- **Server**: `offline_predictions` (see SQL below) and reconciliation job.

**SQL (PostgreSQL)**
```sql
CREATE TABLE offline_predictions (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  device_ts TIMESTAMPTZ NOT NULL,
  client_model JSONB NOT NULL,
  topk JSONB NOT NULL,
  embedding VECTOR(384),
  reconciled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 1.8 Acceptance Criteria
- **Latency**: P50 ≤ 1.8s, P95 ≤ 2.5s for 1080p input on mid‑tier device.  
- **Accuracy delta**: Local top‑1 within 1 class of server top‑1 for ≥70% of clear photos.  
- **Sync correctness**: Exactly‑once insertion (no duplicates) verified by idempotency key.

### 1.9 Tests (Executable‑Spec Sketch)
- Given airplane mode, when `infer()` on sample set, then receive non‑empty `topk` within 2.5s.  
- Given network restored, when `sync.queue.flush()`, then server returns 207 and marks client items `synced=true`.

### 1.10 Metrics
- `offline.infer.ms`, `offline.sync.batch_size`, `offline.sync.fail_ratio`, `offline.top1_match_rate`.

---

## 2) Context‑Aware Care Plans (v2)

### 2.1 Goals
- Generate species‑aware, context‑aware care plans using user logs, local weather, container size, and light readings.  
- Plans are deterministic and explainable (rule + ML hybrid), diff‑able across revisions.

### 2.2 Inputs
- Species (taxonomy id), pot size, medium, location tag, **light readings** (see §3), last water/fertilize, climate region, forecast (7‑day).

### 2.3 Data Model
**Table** `care_plans_v2`
```sql
CREATE TABLE care_plans_v2 (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  plant_id UUID NOT NULL REFERENCES user_plants(id),
  version INT NOT NULL,
  plan JSONB NOT NULL,
  rationale JSONB NOT NULL,
  valid_from TIMESTAMPTZ NOT NULL,
  valid_to TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(plant_id, version)
);
```

**Plan JSON (contract)**
```json
{
  "watering": {"interval_days": 6, "amount_ml": 250, "next_due": "2025-09-07T12:00:00Z"},
  "fertilizer": {"interval_days": 30, "type": "balanced_10_10_10"},
  "light_target": {"ppfd_min": 100, "ppfd_max": 250, "recommendation": "bright_indirect"},
  "alerts": ["heatwave_adjust_-1day", "repot_if_rootbound"],
  "review_in_days": 14
}
```

**Rationale JSON** contains features and rules fired, e.g.:
```json
{"features": {"avg_ppfd": 140, "temp_7d_max": 36}, "rules_fired": ["heatwave_adjustment", "ficus_profile_v3"], "confidence": 0.78}
```

### 2.4 API
- **POST** `/api/v1/care-plans/{plant_id}:generate`  
- **GET** `/api/v1/care-plans/{plant_id}?latest=true`  
- **POST** `/api/v1/care-plans/{plant_id}:acknowledge` (user accepts plan → freeze version)

### 2.5 Algorithm (Deterministic Core + ML Hints)
1. Compute context features (aggregates of logs, light, forecast).  
2. Apply species profile rules (YAML driven; versioned).  
3. Apply climate modifiers (heatwave/cold‑snap).  
4. Blend ML regressors for interval nudges (bounded ±30%).  
5. Emit rationale with rule & model weights.

### 2.6 Acceptance Criteria
- Plan generation ≤ 300ms P95 server‑side.  
- Any change in inputs MUST produce a diffable change in `plan` or `rationale`.  
- Clients can render plan without hidden fields (no derived surprises).

### 2.7 Metrics
- `care.plan.generate.ms`, `care.plan.version_changes`, `care.plan.user_overrides_rate`.

---

## 3) Sensor & Photo Telemetry (Light Intensity + Growth)

### 3.1 Goals
- Measure light intensity (lux → PPFD est.) via ALS/Camera/BLE; attach to plants and locations.  
- Passive growth tracking from periodic photos; compute simple deltas.

### 3.2 Data Model
**Table** `light_readings`
```sql
CREATE TABLE light_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  plant_id UUID,
  location_tag TEXT,
  source TEXT CHECK (source IN ('ALS','CAMERA','BLE')),
  lux REAL NOT NULL,
  ppfd_est REAL,
  light_source_profile TEXT CHECK (light_source_profile IN ('sun','white_led','other')),
  device_model TEXT,
  calibration_profile_id TEXT,
  taken_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

**Table** `growth_photos`
```sql
CREATE TABLE growth_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  plant_id UUID NOT NULL,
  s3_uri TEXT NOT NULL,
  width INT, height INT,
  taken_at TIMESTAMPTZ NOT NULL,
  metrics JSONB, -- e.g., {"leaf_area_px": 18234, "height_px": 812}
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 3.3 APIs
- **POST** `/api/v1/telemetry/light` (single) and `/telemetry/light:batch`  
- **GET** `/api/v1/telemetry/light?plant_id=…&from=…&to=…`  
- **POST** `/api/v1/telemetry/growth-photo:upload` → pre‑signed URL workflow  
- **GET** `/api/v1/telemetry/growth-photo?plant_id=…`

**Light POST body**
```json
{
  "plant_id": "…",
  "location_tag": "South window",
  "source": "CAMERA",
  "lux": 5800,
  "ppfd_est": 105,
  "light_source_profile": "sun",
  "device_model": "iPhone15,4",
  "calibration_profile_id": "cal_v1",
  "taken_at": "2025-09-05T18:58:00Z"
}
```

### 3.4 Client Modules
- `light_meter`: strategies (`ALS`, `Camera`, `BLE`), shared calibration, rate limiter.  
- `growth_tracker`: capture pipeline, background upload, simple delta metrics.  
- Both modules expose pure interfaces; side‑effects (IO) behind adapters.

### 3.5 Acceptance Criteria
- Camera reading variance ≤ 20% vs calibration reference after wizard.  
- BLE reads ≥ 1Hz stable for supported sensors.  
- Growth photo upload handles offline queue with retry/backoff.

### 3.6 Metrics
- `telemetry.light.samples`, `telemetry.light.ppfd.estimate_error`, `telemetry.growth.upload_fail_ratio`.

---

## 5) Smart Community (RAG‑Grounded Answers)

### 5.1 Goals
- Reduce repetitive questions; surface grounded answers from species sheets, prior solved threads, and trusted external docs.  
- Provide citations and local context (user’s plants, region).

### 5.2 Indexing Pipeline
- Sources: species KB, accepted community answers, curated docs.  
- Embed via `text-embedding-3-large` (or local equivalent); store in `pgvector`.  
- Chunking policy: 1–3 paragraphs with overlap 128 tokens.

### 5.3 DB & Schema
```sql
CREATE TABLE rag_corpus (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source TEXT CHECK (source IN ('species','community','external')),
  doc_id TEXT,
  chunk_index INT,
  content TEXT NOT NULL,
  metadata JSONB,
  embedding VECTOR(3072)
);
```

### 5.4 Query API
- **POST** `/api/v1/community/rag-query`
```json
{
  "question": "Brown spots on Ficus lyrata leaves",
  "context": {"user_region": "US-TX", "plant_ids": ["…"]},
  "top_k": 6,
  "max_tokens": 300
}
```
**Response**
```json
{
  "answer": "Likely edema or fungal leaf spot…",
  "citations": [
    {"source": "species", "doc_id": "ficus_lyrata_sheet", "chunk_index": 2},
    {"source": "community", "doc_id": "thread_78122", "chunk_index": 0}
  ],
  "confidence": 0.71
}
```

### 5.5 UX Hooks
- "Suggested answers" beneath the composer; tap to insert with citations.  
- Duplicate detection: warn if near‑duplicate question already exists.

### 5.6 Acceptance Criteria
- ≥ 60% of new posts see at least one suggestion; ≥ 25% are accepted as is or with minor edits.  
- All answers return ≥2 citations when available.

### 5.7 Metrics
- `rag.query.ms`, `rag.suggestion.accept_rate`, `rag.answer.token_cost`, `rag.index.size`.

---

## OpenAPI (excerpt) – Machine‑Readable Contract
```yaml
openapi: 3.0.3
info:
  title: LeafWise Feature Pack
  version: 1.0.0
servers:
  - url: https://api.leafwise.app/api/v1
paths:
  /offline/predictions:batch:
    post:
      operationId: batchOfflinePredictions
      headers:
        Idempotency-Key: { schema: { type: string } }
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                predictions:
                  type: array
                  items: { $ref: '#/components/schemas/LocalPrediction' }
                client_model:
                  type: object
                  properties:
                    name: { type: string }
                    version: { type: string }
      responses:
        '207': { description: Multi-Status }
  /care-plans/{plant_id}:generate:
    post:
      operationId: generateCarePlan
      parameters:
        - name: plant_id
          in: path
          required: true
          schema: { type: string }
      responses:
        '200': { description: OK }
  /telemetry/light:
    post:
      operationId: postLightReading
      responses:
        '201': { description: Created }
  /community/rag-query:
    post:
      operationId: ragQuery
      responses:
        '200': { description: OK }
components:
  schemas:
    LocalPrediction:
      type: object
      properties:
        id: { type: string }
        device_ts: { type: string, format: date-time }
        topk:
          type: array
          items:
            type: object
            properties:
              label: { type: string }
              score: { type: number }
        embedding: { type: string, description: base64 float32[384] }
        calib_version: { type: string }
        synced: { type: boolean }
```

---

## QA Matrix (Acceptance Tests Summary)
| Feature | Case | Given | When | Then |
|---|---|---|---|---|
| Offline AI | Latency | Airplane mode | Infer on 1080p image | P95 ≤ 2.5s |
| Offline AI | Sync | Back online | Flush queue | 207, items marked synced |
| Care Plans v2 | Determinism | Same inputs | Generate | Identical JSON (plan, rationale) |
| Care Plans v2 | Diffability | Change pot size | Generate | `interval_days` decreases; rationale logs rule |
| Telemetry | Camera | Post‑calibration | Capture | |variance ≤ 20% vs ref|
| Telemetry | Offline | No network | Submit batch | Retries with backoff; eventual 201 |
| RAG | Citations | Index warm | Query | ≥2 citations present |
| RAG | Duplicate warn | Similar question exists | Compose | UI shows warning & link |

---

## Rollout & Safeguards
- **Phase 0 (dark)**: Endpoints live behind flags; synthetic traffic only.  
- **Phase 1 (internal)**: Dogfood with staff devices; telemetry gating.  
- **Phase 2 (5% canary)**: Auto‑rollback on SLO breach (latency/error rate thresholds).  
- **Phase 3 (100%)**: Flags remain for kill‑switch.

**SLOs**  
- API Availability 99.9% monthly.  
- P95 latency: offline sync ≤ 300ms; care‑plan generate ≤ 300ms; rag‑query ≤ 1200ms.

---

## Task Breakdown (Minimal‑Error Execution)
- Generate server/client SDKs from OpenAPI.  
- Enforce JSON‑Schema validation at ingress.  
- Adopt typed DTOs and boundary adapters; all domain logic pure functions.  
- Add contract tests that run against a local mocked server (pact‑style).  
- Add e2e golden tests for care plan JSON snapshots.

---

## Nice‑to‑Have (If Time Allows)
- Background model download manager with checksum + rollback.  
- RAG moderation layer (hallucination guardrails, citation verifier).  
- Telemetry calibration profile marketplace (share community calibrations by device).

