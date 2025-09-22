# Critical Error Catalog and Prioritization

## Backend Critical Errors (BLOCKING)

### 1. Pydantic Model Recursion Error (CRITICAL)
**Status**: BLOCKING - Application cannot start
**Error**: `RecursionError: maximum recursion depth exceeded`
**Location**: Pydantic model definitions
**Impact**: Complete backend startup failure
**Priority**: 1 (Must fix first)

### 2. Missing Service Dependencies (CRITICAL)
**Status**: BLOCKING - Import errors prevent startup
**Affected Services**:
- `smart_community_ml_integration` - Referenced but incomplete
- RAG infrastructure services - Missing implementations
- Analytics services - Incomplete implementations
**Priority**: 2 (Fix after Pydantic issues)

### 3. FastAPI Response Model Issues (HIGH)
**Status**: BLOCKING - Endpoints cannot be registered
**Error**: AsyncSession in response model inference
**Impact**: API endpoints fail to register
**Priority**: 3 (Fix after imports resolved)

### 4. Database Schema Issues (HIGH)
**Status**: BLOCKING - Migration and model issues
**Issues**:
- Reserved attribute name `metadata` in Story model
- Potential migration conflicts
**Priority**: 4 (Fix after API issues)

## Frontend Critical Errors (HIGH)

### 1. Deprecated API Usage (HIGH)
**Status**: NON-BLOCKING but generates 394 warnings
**Issue**: `withOpacity` deprecated, should use `withValues`
**Files Affected**: 394 instances across multiple files
**Priority**: 5 (Fix after backend is stable)

### 2. Unused Code and Imports (MEDIUM)
**Status**: NON-BLOCKING but creates noise
**Issues**:
- Unused imports (e.g., `dart:convert`)
- Unused local variables
- Unused generated JSON functions
- Unused element declarations
**Priority**: 6 (Cleanup after critical fixes)

### 3. Version Conflicts (MEDIUM)
**Status**: NON-BLOCKING but may cause build issues
**Issues**:
- `retrofit_generator: 9.2.0` conflicts with `retrofit: ^4.0.3`
- `analyzer: 6.11.0` version specification
**Priority**: 7 (Fix during dependency cleanup)

## Environment and Configuration Issues (HIGH)

### 1. Missing Environment Configuration (HIGH)
**Status**: BLOCKING - Services cannot connect
**Missing**:
- `.env` file with database credentials
- API keys for external services
- Redis configuration
- AWS credentials
**Priority**: 3 (Needed for service testing)

### 2. Database Setup (HIGH)
**Status**: BLOCKING - No database connection
**Issues**:
- PostgreSQL not configured
- Connection string missing
- Migration state unknown
**Priority**: 4 (Needed for model testing)

## Prioritized Fix Order

### Phase 1: Critical Backend Fixes (Days 1-2)
1. **Fix Pydantic Model Recursion** - Use forward references and proper imports
2. **Create Missing Service Stubs** - Implement basic functionality for missing services
3. **Fix FastAPI Response Models** - Remove AsyncSession from response inference
4. **Environment Setup** - Create .env file and basic configuration

### Phase 2: Database and API Stabilization (Day 3)
5. **Fix Database Schema Issues** - Rename reserved attributes, test migrations
6. **Test API Endpoints** - Ensure endpoints can be registered and respond
7. **Basic Integration Testing** - Test critical user flows

### Phase 3: Frontend Cleanup (Day 4)
8. **Fix Deprecated API Usage** - Replace withOpacity with withValues
9. **Clean Up Unused Code** - Remove unused imports and variables
10. **Fix Version Conflicts** - Update dependency versions

### Phase 4: Optimization and Polish (Day 5)
11. **Performance Testing** - Test under load
12. **Error Handling** - Improve error messages and recovery
13. **Documentation** - Update setup and deployment docs

## Blocking vs Non-Blocking Issues

### BLOCKING (Must fix for basic functionality):
- Pydantic recursion errors
- Missing service dependencies
- FastAPI response model issues
- Missing environment configuration
- Database connection issues

### NON-BLOCKING (Can be fixed incrementally):
- Deprecated Flutter API usage
- Unused code and imports
- Version conflicts (if not causing build failures)
- Performance optimizations
- Code style issues

## Success Criteria for Each Phase

### Phase 1 Success:
- Backend starts without import errors
- No Pydantic recursion errors
- Basic services can be imported

### Phase 2 Success:
- Database connection established
- API endpoints respond to requests
- Basic CRUD operations work

### Phase 3 Success:
- Flutter app builds without critical errors
- Deprecated API warnings resolved
- Clean code analysis results

### Phase 4 Success:
- End-to-end user flows work
- Performance meets requirements
- Production-ready deployment