# LeafWise API Backend

FastAPI-based backend for the LeafWise platform with real-time messaging, stories, and AI-enhanced plant care features.

## Features

- **Authentication & User Management**: JWT-based auth with FastAPI-Users
- **Real-time Messaging**: WebSocket-based chat with disappearing messages
- **Stories System**: 24-hour ephemeral content sharing
- **Friend Management**: Friend requests, blocking, and social connections
- **File Storage**: AWS S3 integration with LocalStack for development
- **Database**: PostgreSQL with async SQLAlchemy and pgvector for future RAG
- **Caching**: Redis for sessions and real-time features
- **AI Plant Identification**: Advanced plant identification using OpenAI Vision API

## AI Plant Identification

The application includes sophisticated AI-powered plant identification using OpenAI's Vision API:

### Features
- **Image Upload & Analysis**: Upload plant photos for instant AI identification
- **Species Matching**: Automatic matching with plant species database
- **Confidence Scoring**: AI provides confidence scores for identification accuracy
- **Multiple Suggestions**: Alternative plant suggestions when uncertain
- **Care Recommendations**: Personalized care tips based on identified species
- **Plant Characteristics**: Detailed analysis of leaf shape, growth habits, etc.

### API Endpoints

#### Upload & Identify
```
POST /api/v1/plant-identification/upload
```
Upload a plant image and get AI identification results with database storage.

#### Analyze Only
```
POST /api/v1/plant-identification/analyze
```
Analyze a plant image without saving to database (for quick identification).

#### Get AI Details
```
GET /api/v1/plant-identification/{id}/ai-details
```
Get detailed AI analysis for a specific identification.

### Configuration

Set your OpenAI API key in the environment:
```bash
export OPENAI_API_KEY="your-openai-api-key"
```

Or add it to your `.env` file:
```
OPENAI_API_KEY=your-openai-api-key
```

### Image Processing

- **Supported Formats**: JPEG, PNG, WebP
- **Max File Size**: 10MB
- **Auto-Resize**: Images larger than 1920x1920 are automatically resized
- **Format Conversion**: RGBA/Transparency converted to RGB for compatibility

### AI Analysis

The AI provides comprehensive plant analysis including:

- **Primary Identification**: Most likely plant species
- **Alternative Suggestions**: Multiple possibilities with confidence scores
- **Plant Characteristics**: Leaf shape, arrangement, flower color, growth habit
- **Care Recommendations**: Light, water, soil requirements, difficulty level
- **Scientific Names**: Botanical nomenclature when available

### Fallback Behavior

When OpenAI API is unavailable:
- Service gracefully falls back to mock identification
- Error handling preserves user experience
- Detailed error logging for debugging

## Quick Start

### Prerequisites

- Python 3.11+
- Docker and Docker Compose
- PostgreSQL (or use Docker)
- Redis (or use Docker)

### Development Setup

1. **Clone and navigate to backend**:
   ```bash
   cd backend
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Start services with Docker**:
   ```bash
   # From project root
   docker-compose up postgres redis localstack
   ```

5. **Run database migrations**:
   ```bash
   # Initialize Alembic (first time only)
   alembic revision --autogenerate -m "Initial migration"
   
   # Apply migrations
   alembic upgrade head
   ```

6. **Start the API server**:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

### Using Docker (Full Stack)

```bash
# Start all services including backend
docker-compose --profile full up
```

## API Documentation

Once running, visit:
- **Interactive API Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/api/v1/openapi.json

## Project Structure

```
backend/
├── app/
│   ├── api/                 # API routes and endpoints
│   │   └── api_v1/
│   │       ├── endpoints/   # Individual endpoint modules
│   │       └── api.py       # Main API router
│   ├── core/                # Core configuration
│   │   ├── config.py        # Settings and configuration
│   │   ├── database.py      # Database setup
│   │   └── websocket.py     # WebSocket manager
│   ├── models/              # SQLAlchemy models
│   ├── schemas/             # Pydantic schemas
│   ├── services/            # Business logic
│   └── main.py              # FastAPI application
├── alembic/                 # Database migrations
├── database/                # Database scripts
├── .env                     # Environment variables
├── requirements.txt         # Python dependencies
└── Dockerfile              # Container configuration
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh access token
- `GET /api/v1/auth/me` - Get current user info
- `PUT /api/v1/auth/me` - Update user profile
- `POST /api/v1/auth/logout` - Logout user

### Users
- `GET /api/v1/users/search` - Search users
- `GET /api/v1/users/{username}` - Get user profile
- `GET /api/v1/users/{user_id}/profile` - Get user by ID
- `PUT /api/v1/users/profile` - Update profile
- `GET /api/v1/users/stats` - Get user statistics
- `GET /api/v1/users/suggestions` - Get friend suggestions

### Messages
- `POST /api/v1/messages/send` - Send message
- `GET /api/v1/messages/conversations` - Get conversations
- `GET /api/v1/messages/conversation/{user_id}` - Get conversation
- `PUT /api/v1/messages/{message_id}/read` - Mark as read
- `DELETE /api/v1/messages/{message_id}` - Delete message

### Stories
- `POST /api/v1/stories/create` - Create story
- `GET /api/v1/stories/feed` - Get stories feed
- `GET /api/v1/stories/user/{user_id}` - Get user stories
- `GET /api/v1/stories/my` - Get own stories
- `PUT /api/v1/stories/{story_id}/view` - Mark story as viewed
- `DELETE /api/v1/stories/{story_id}` - Delete story

### Friends
- `POST /api/v1/friends/request` - Send friend request
- `PUT /api/v1/friends/accept/{request_id}` - Accept request
- `PUT /api/v1/friends/decline/{request_id}` - Decline request
- `DELETE /api/v1/friends/{friend_id}` - Remove friend
- `GET /api/v1/friends/list` - Get friends list
- `POST /api/v1/friends/block/{user_id}` - Block user

### WebSocket
- `WS /api/v1/ws/connect` - WebSocket connection for real-time messaging

## Database Schema

The application uses PostgreSQL with the following main tables:

- **users**: User accounts and profiles
- **messages**: Chat messages with disappearing functionality
- **stories**: 24-hour ephemeral content
- **story_views**: Story view tracking
- **friendships**: Friend relationships and requests
- **plant_identifications**: Plant identification records

## Environment Variables

Key environment variables (see `.env.example`):

```bash
# Database
POSTGRES_SERVER=localhost
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=leafwise_db

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Security
SECRET_KEY=your-secret-key
ACCESS_TOKEN_EXPIRE_MINUTES=11520

# AWS S3 (LocalStack for dev)
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
S3_BUCKET_NAME=plant-social-media
```

## Development Commands

```bash
# Database migrations
alembic revision --autogenerate -m "Description"
alembic upgrade head
alembic downgrade -1

# Code formatting
black app/
isort app/
flake8 app/

# Testing
pytest
pytest --cov=app

# Run with auto-reload
uvicorn app.main:app --reload
```

## WebSocket Usage

Connect to WebSocket for real-time features:

```javascript
const ws = new WebSocket('ws://localhost:8000/api/v1/ws/connect?token=YOUR_JWT_TOKEN');

// Send message
ws.send(JSON.stringify({
  type: 'send_message',
  data: {
    recipient_id: 'user-uuid',
    content: 'Hello!',
    message_type: 'text'
  }
}));

// Handle incoming messages
ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log('Received:', message);
};
```

## Production Deployment

1. **Environment Setup**:
   - Set production environment variables
   - Configure real AWS S3 credentials
   - Set strong SECRET_KEY
   - Configure production database

2. **Database**:
   - Run migrations: `alembic upgrade head`
   - Set up database backups
   - Configure connection pooling

3. **Security**:
   - Enable HTTPS
   - Configure CORS properly
   - Set up rate limiting
   - Enable security headers

4. **Monitoring**:
   - Set up logging
   - Configure health checks
   - Monitor database performance
   - Track API metrics

## Troubleshooting

### Common Issues

1. **Database Connection Error**:
   - Ensure PostgreSQL is running
   - Check connection string in `.env`
   - Verify database exists

2. **Redis Connection Error**:
   - Ensure Redis is running
   - Check Redis host/port configuration

3. **Migration Issues**:
   - Check Alembic configuration
   - Ensure models are imported in `env.py`
   - Verify database permissions

4. **WebSocket Connection Issues**:
   - Check JWT token validity
   - Verify WebSocket URL
   - Check CORS configuration

### Logs

```bash
# View application logs
docker-compose logs backend

# View database logs
docker-compose logs postgres

# View Redis logs
docker-compose logs redis
```

## Contributing

1. Follow the existing code style
2. Add tests for new features
3. Update documentation
4. Run linting before committing
5. Create meaningful commit messages

## License

This project is part of the LeafWise platform development challenge.