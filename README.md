# 🌱 LeafWise - AI-Enhanced Plant Care Community

> A revolutionary plant-focused social platform that combines Snapchat-like features with advanced AI capabilities to create the ultimate gardening community experience.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://postgresql.org/)
[![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)](https://openai.com/)

---

## 🎯 Project Overview

LeafWise is a modern social messaging platform focused on plant enthusiasts, built with Flutter and FastAPI. This project implements core Snapchat features with plant-specific enhancements and AI-powered recommendations.

## 🚀 Phase 1: Core MVP - COMPLETED

### ✅ Implemented Features

#### Backend Infrastructure
- **FastAPI Application**: Modern async Python backend with automatic API documentation
- **Database Setup**: PostgreSQL with SQLAlchemy ORM and Alembic migrations
- **Real-time Messaging**: WebSocket-based chat system with connection management
- **Authentication System**: JWT-based auth with FastAPI-Users integration
- **File Storage**: AWS S3 integration with LocalStack for development
- **Caching Layer**: Redis for sessions, real-time features, and performance
- **Containerization**: Docker Compose setup for development environment

#### Core API Endpoints
- **Authentication**: Registration, login, token refresh, profile management
- **User Management**: Search, profiles, statistics, friend suggestions
- **Messaging System**: Send/receive messages, conversations, read receipts
- **Stories Feature**: Create, view, and manage 24-hour ephemeral content
- **Friend Management**: Requests, acceptance, blocking, close friends
- **WebSocket API**: Real-time messaging and notifications

#### Database Schema
- **Users**: Complete user profiles with plant-specific fields
- **Messages**: Chat messages with disappearing functionality and media support
- **Stories**: Ephemeral content with privacy levels and view tracking
- **Friendships**: Social connections with status management
- **Story Views**: Analytics for story engagement

#### Development Environment
- **Docker Compose**: PostgreSQL, Redis, and LocalStack services
- **Database Migrations**: Alembic setup with automatic schema management
- **Environment Configuration**: Development and production settings
- **Startup Scripts**: Automated development environment setup
- **API Documentation**: Interactive Swagger UI and ReDoc

### 🌟 Key Features

- **🔍 AI Plant Identification**: Instant plant species recognition using OpenAI Vision API
- **🤖 RAG-Powered Care Advice**: Personalized plant care recommendations based on your collection and experience
- **📸 Ephemeral Plant Stories**: Snapchat-style disappearing content focused on plant care and growth
- **🎭 Plant-Themed AR Filters**: Interactive AR effects for plant health visualization and growth tracking
- **💬 Expert Community**: Connect with verified horticulturists and experienced gardeners
- **📊 Smart Analytics**: Track your plant care journey with AI-powered insights
- **🛒 Plant Marketplace**: Secure trading platform for plant enthusiasts

---

## 🏗️ Architecture & Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile development
- **Riverpod** - State management and dependency injection
- **AR Core/ARKit** - Augmented reality features
- **WebSocket** - Real-time messaging

### Backend
- **FastAPI** - High-performance Python web framework
- **PostgreSQL** - Primary database with pgvector extension
- **Redis** - Caching and real-time pub/sub messaging
- **SQLAlchemy** - Async ORM for database operations

### AI & ML
- **OpenAI API** - GPT-4 for content generation and plant identification
- **pgvector** - Vector database for RAG implementation
- **Custom ML Models** - Plant health analysis and prediction

### Infrastructure
- **AWS S3 + CloudFront** - Media storage and CDN
- **FastAPI-Users** - Authentication and user management
- **Docker** - Containerization and deployment

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.0+)
- **Python** (3.11+)
- **PostgreSQL** (14+)
- **Redis** (6+)
- **Docker** (optional, recommended)

### Quick Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd snap
   ```

2. **Backend Setup**
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Database Setup**
   ```bash
   # Create PostgreSQL database
   createdb leafwise_db
   
   # Run migrations
   alembic upgrade head
   ```

4. **Frontend Setup**
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

5. **Environment Configuration**
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Add your API keys:
   # - OpenAI API Key
   # - AWS S3 credentials
   # - Database connection strings
   ```

---

## 📁 Project Structure

Our codebase follows **AI-first development principles** with strict modularity and scalability guidelines:

### Frontend (Flutter)
```
lib/
├── core/                    # Core infrastructure
│   ├── constants/           # App-wide constants
│   ├── errors/             # Error handling
│   ├── network/            # API clients
│   └── utils/              # Utility functions
├── features/               # Feature-based modules
│   ├── auth/               # Authentication
│   ├── camera/             # Camera & AR features
│   ├── chat/               # Messaging
│   ├── discover/           # RAG-powered discovery
│   ├── profile/            # User profiles
│   └── plant_care/         # Plant care features
├── shared/                 # Shared components
│   ├── widgets/            # Reusable UI components
│   ├── models/             # Data models
│   └── services/           # Shared services
└── main.dart              # App entry point
```

### Backend (FastAPI)
```
app/
├── api/                    # API layer
│   ├── endpoints/          # Route handlers
│   └── middleware/         # Custom middleware
├── core/                   # Core configuration
├── models/                 # SQLAlchemy models
├── schemas/                # Pydantic schemas
├── services/               # Business logic
│   ├── rag_service.py      # RAG implementation
│   ├── plant_service.py    # Plant care logic
│   └── ai_service.py       # AI integrations
└── utils/                  # Utility functions
```

---

## 🎨 Development Guidelines

### Code Quality Standards

- **📏 File Size Limit**: Maximum 500 lines per file
- **📝 Documentation**: All public functions must have comprehensive docstrings
- **🏷️ Naming**: Descriptive names following language conventions
- **🧩 Modularity**: Features should be self-contained and reusable
- **🧪 Testing**: Minimum 80% test coverage for critical paths

### AI-First Principles

- **🔗 RAG Integration**: All content leverages retrieval-augmented generation
- **🎯 Personalization**: Features adapt to user behavior and preferences
- **🧠 Context Awareness**: AI considers user's current situation and needs
- **📈 Continuous Learning**: System improves based on user feedback
- **🔍 Transparency**: AI decisions are explainable to users

### Naming Conventions

#### Files & Directories
- **Flutter**: `snake_case` (user_profile_screen.dart)
- **Python**: `snake_case` (plant_service.py)
- **Classes**: `PascalCase` (UserProfileScreen, PlantService)
- **Variables**: `camelCase` (isLoading, hasError)
- **Constants**: `SCREAMING_SNAKE_CASE` (API_BASE_URL)

#### Database
- **Tables**: `snake_case` (user_plants, care_logs)
- **Columns**: `snake_case` (created_at, plant_species_id)
- **Indexes**: `idx_tablename_column` (idx_users_email)

---

## 🔄 Development Phases

Our development follows an iterative approach with functional deliverables at each phase:

### Phase 0: Setup & Foundation (1-2 days)
- ✅ Project infrastructure setup
- ✅ Basic authentication
- ✅ Core navigation
- ✅ Minimal camera integration

### Phase 1: Core MVP (2-3 days)
- 💬 Real-time messaging system
- 📖 Stories with disappearing content
- 👥 Friend management
- 📁 Media storage (AWS S3)

### Phase 2: Plant Features (2-3 days)
- 🔍 AI plant identification
- 🌿 Plant care recommendations
- 🎭 Plant-themed AR filters
- 🏡 Plant community features

### Phase 3: RAG Enhancement (2-3 days)
- 🧠 Vector database integration
- 🎯 Personalized AI recommendations
- ✍️ Intelligent content generation
- 🤝 Smart community matching

### Phase 4: Polish & Advanced (3-4 days)
- ⚡ Performance optimization
- 🥽 Advanced AR features
- 🛒 Plant marketplace
- 👨‍🔬 Expert network

> 📋 Detailed phase documentation available in `_docs/phases/`

---

## 🎯 User Experience

### Target Audience
**Plant enthusiasts and gardeners (20-30 years old)**
- 🌱 Beginner gardeners seeking advice
- 🌿 Experienced plant parents sharing knowledge
- 🏙️ Urban gardeners with limited space
- 🌺 Plant collectors showcasing finds
- 🎨 Garden designers and landscapers

### Core User Flows

1. **New Plant Parent Seeking Help**
   - Capture struggling plant photo → AI identifies issue → Get expert advice

2. **Experienced Gardener Sharing Knowledge**
   - Discover beginner questions → Create helpful AR-enhanced responses

3. **Seasonal Garden Planning**
   - Browse RAG-curated seasonal content → Save plants to wishlist → Share plans

---

## 🔒 Security & Privacy

- **🔐 JWT Authentication**: Secure token-based authentication with refresh rotation
- **🛡️ Input Validation**: Comprehensive sanitization of all user inputs
- **🔒 Data Encryption**: End-to-end encryption for sensitive data
- **📊 GDPR Compliance**: Full compliance with data protection regulations
- **🚫 Rate Limiting**: API protection against abuse and DDoS

---

## 📊 Performance Targets

- **🚀 App Launch**: Under 3 seconds on average devices
- **⚡ API Response**: 95% of requests under 100ms
- **🔍 Plant ID**: Species identification under 5 seconds
- **💬 Real-time**: Sub-second message delivery
- **💾 Memory**: Stable usage during extended sessions

---

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Follow our coding standards** (see project-rules.md)
4. **Write comprehensive tests**
5. **Commit with descriptive messages**
6. **Push to your branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

### Development Workflow

- **🔍 Code Review**: All PRs require review
- **🧪 Testing**: Automated tests must pass
- **📏 Standards**: Code must follow project conventions
- **📝 Documentation**: Update docs for new features

---

## 📚 Documentation

- **📋 [Project Rules](project-rules.md)** - Development standards and conventions
- **🛠️ [Tech Stack](tech-stack.md)** - Technology choices and best practices
- **🎨 [UI Guidelines](ui-rules.md)** - Design principles and patterns
- **🎭 [Theme Guide](theme-rules.md)** - Visual style and branding
- **👤 [User Flow](user-flow.md)** - User journey and feature requirements
- **🗺️ [Development Roadmap](_docs/phases/development-roadmap.md)** - Complete development plan

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **OpenAI** for providing cutting-edge AI capabilities
- **Flutter Team** for the excellent cross-platform framework
- **FastAPI** for the high-performance backend framework
- **Plant Community** for inspiration and domain expertise

---

**Built with ❤️ for the plant community**

*Transform your plant care journey with AI-powered insights and community wisdom.*