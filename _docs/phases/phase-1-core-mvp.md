# Phase 1: Core MVP - Essential Social Features

**Duration**: 2-3 days  
**Goal**: Build a functional Snapchat clone with core messaging, camera, and social features

---

## Phase Overview

This phase transforms the basic setup into a fully functional social messaging platform. Users will be able to capture photos/videos, send disappearing messages, view stories, and manage their social connections. This represents the core MVP that delivers the primary value proposition of ephemeral social sharing.

---

## Core Deliverables

### 1. Enhanced Camera & Content Creation

**Objective**: Build comprehensive photo/video capture with basic editing

**Tasks**:
- [x] Implement video recording functionality
- [x] Add basic camera filters and effects
- [x] Create content editing interface (text, drawings)
- [x] Implement timer controls for disappearing content
- [x] Add flash and camera switching controls

**Acceptance Criteria**:
- Users can record videos up to 60 seconds
- Basic filters (brightness, contrast, saturation) work
- Text overlay with multiple fonts and colors
- Drawing tools with different brush sizes
- Timer settings (1-10 seconds) for disappearing messages

### 2. Messaging System

**Objective**: Implement real-time messaging with disappearing content

**Tasks**:
- [x] Create message model and database schema
- [x] Implement WebSocket connections for real-time messaging
- [x] Build chat interface with message bubbles
- [x] Add disappearing message logic with timers
- [x] Implement message status indicators (sent, delivered, viewed)

**Acceptance Criteria**:
- Messages send and receive in real-time
- Photos/videos disappear after viewing timer expires
- Message status shows delivery and read receipts
- Chat history persists for non-disappearing messages
- Typing indicators work correctly

### 3. Stories Feature

**Objective**: Implement story posting and viewing functionality

**Tasks**:
- [x] Create story model and storage system
- [x] Build story creation and posting interface
- [x] Implement story viewing with tap navigation
- [x] Add story privacy controls (public, friends only)
- [x] Create story archive functionality

**Acceptance Criteria**:
- Users can post photos/videos to their story
- Stories auto-advance and can be manually navigated
- Stories disappear after 24 hours
- Privacy settings control story visibility
- Users can view who has seen their stories

### 4. Friend Management System

**Objective**: Enable users to connect and manage social relationships

**Tasks**:
- [x] Implement friend request system
- [x] Create user search and discovery
- [x] Build friends list interface
- [x] Add contact synchronization
- [x] Implement blocking and privacy controls

**Acceptance Criteria**:
- Users can send and receive friend requests
- Search finds users by username or display name
- Friends list shows online status
- Contact sync suggests friends from phone contacts
- Blocked users cannot send messages or view content

### 5. File Storage & Media Management

**Objective**: Implement secure file upload and storage system

**Tasks**:
- [x] Set up AWS S3 integration for media storage
- [x] Implement secure file upload endpoints
- [x] Add image/video compression and optimization
- [x] Create media cleanup for expired content
- [ ] Implement CDN integration for fast delivery

**Acceptance Criteria**:
- Photos and videos upload reliably to cloud storage
- Media is compressed appropriately for mobile
- Expired content is automatically deleted
- Media loads quickly from CDN
- Upload progress indicators work correctly

---

## Technical Implementation

### Backend Architecture

**Real-time Messaging**:
```python
# WebSocket connection manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []
    
    async def connect(self, websocket: WebSocket, user_id: str):
        await websocket.accept()
        self.active_connections.append(websocket)
    
    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)
```

**Message Model**:
```python
class Message(Base):
    __tablename__ = "messages"
    
    id = Column(UUID, primary_key=True, default=uuid.uuid4)
    sender_id = Column(UUID, ForeignKey("users.id"))
    recipient_id = Column(UUID, ForeignKey("users.id"))
    content_type = Column(String)  # text, image, video
    content_url = Column(String, nullable=True)
    text_content = Column(Text, nullable=True)
    disappear_after = Column(Integer)  # seconds
    created_at = Column(DateTime, default=datetime.utcnow)
    viewed_at = Column(DateTime, nullable=True)
```

### Frontend Architecture

**State Management**:
```dart
// Message provider for real-time updates
final messageProvider = StateNotifierProvider<MessageNotifier, MessageState>(
  (ref) => MessageNotifier(ref.read(webSocketServiceProvider)),
);

class MessageNotifier extends StateNotifier<MessageState> {
  MessageNotifier(this._webSocketService) : super(MessageState.initial());
  
  final WebSocketService _webSocketService;
  
  Future<void> sendMessage(Message message) async {
    // Send message logic
  }
}
```

**Camera Integration**:
```dart
class CameraScreen extends ConsumerStatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    // Camera initialization logic
  }
}
```

---

## Database Schema Updates

### New Tables

```sql
-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES users(id),
    recipient_id UUID REFERENCES users(id),
    content_type VARCHAR(20) NOT NULL,
    content_url TEXT,
    text_content TEXT,
    disappear_after INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    viewed_at TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Stories table
CREATE TABLE stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    content_url TEXT NOT NULL,
    content_type VARCHAR(20) NOT NULL,
    caption TEXT,
    privacy_level VARCHAR(20) DEFAULT 'friends',
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '24 hours'
);

-- Friendships table
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID REFERENCES users(id),
    addressee_id UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Story views table
CREATE TABLE story_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id UUID REFERENCES stories(id),
    viewer_id UUID REFERENCES users(id),
    viewed_at TIMESTAMP DEFAULT NOW()
);
```

### Indexes for Performance

```sql
-- Message queries
CREATE INDEX idx_messages_sender_recipient ON messages(sender_id, recipient_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);

-- Story queries
CREATE INDEX idx_stories_user_expires ON stories(user_id, expires_at);
CREATE INDEX idx_stories_created_at ON stories(created_at);

-- Friendship queries
CREATE INDEX idx_friendships_users ON friendships(requester_id, addressee_id);
CREATE INDEX idx_friendships_status ON friendships(status);
```

---

## API Endpoints

### Messaging Endpoints
```
POST /api/v1/messages/send
GET /api/v1/messages/conversation/{user_id}
PUT /api/v1/messages/{message_id}/view
DELETE /api/v1/messages/{message_id}
```

### Stories Endpoints
```
POST /api/v1/stories/create
GET /api/v1/stories/feed
GET /api/v1/stories/{story_id}
PUT /api/v1/stories/{story_id}/view
DELETE /api/v1/stories/{story_id}
```

### Friends Endpoints
```
POST /api/v1/friends/request
PUT /api/v1/friends/accept/{request_id}
DELETE /api/v1/friends/remove/{friend_id}
GET /api/v1/friends/list
GET /api/v1/friends/search?q={query}
```

---

## Success Metrics

- [x] Users can send and receive messages in real-time
- [x] Photos and videos upload and display correctly
- [x] Disappearing messages work with accurate timers
- [x] Stories post and can be viewed by friends
- [x] Friend requests and management work smoothly
- [x] Camera captures high-quality photos and videos
- [x] App handles offline/online state transitions
- [x] Performance remains smooth with multiple conversations

---

## Relevant Files

**Backend Core**:
- `app/api/api_v1/endpoints/messages.py` - Message handling endpoints (implemented)
- `app/api/api_v1/endpoints/stories.py` - Story management endpoints (implemented)
- `app/api/api_v1/endpoints/friends.py` - Friend management endpoints (implemented)
- `app/api/api_v1/endpoints/websocket.py` - WebSocket endpoint for real-time messaging (implemented)
- `app/services/message_service.py` - Message business logic service (implemented)
- `app/services/story_service.py` - Story management service (implemented)
- `app/services/friendship_service.py` - Friend management service (implemented)
- `app/services/file_service.py` - File upload and processing service (implemented)
- `app/models/message.py` - Message database model (implemented)
- `app/models/story.py` - Story database model (implemented)
- `app/models/friendship.py` - Friendship database model (implemented)

**Frontend Core**:
- `lib/features/camera/presentation/screens/` - Camera and content creation (implemented)
- `lib/features/chat/presentation/screens/` - Messaging interface (implemented)
- `lib/features/messages/presentation/widgets/` - Message UI components (implemented)
- `lib/features/stories/presentation/screens/` - Story creation and viewing (implemented)
- `lib/features/friends/presentation/screens/` - Friend management (implemented)
- `lib/core/services/api_service.dart` - API communication service (implemented)
- `lib/core/services/storage_service.dart` - Local storage service (implemented)

**Frontend Files**:
- `lib/features/camera/presentation/screens/camera_screen.dart` - Enhanced camera with controls
- `lib/features/chat/presentation/screens/chat_screen.dart` - Chat list interface
- `lib/features/chat/presentation/screens/conversation_screen.dart` - Individual chat screen
- `lib/features/stories/presentation/screens/stories_screen.dart` - Stories feed
- `lib/features/stories/presentation/screens/story_creation_screen.dart` - Story creation interface
- `lib/features/stories/presentation/screens/story_viewer_screen.dart` - Story viewing with navigation
- `lib/features/friends/presentation/screens/friends_screen.dart` - Friends management
- `lib/features/friends/presentation/screens/add_friends_screen.dart` - Friend discovery
- `lib/features/profile/presentation/screens/profile_screen.dart` - User profile
- `lib/features/profile/presentation/screens/profile_edit_screen.dart` - Profile editing

**Infrastructure**:
- `database/migrations/002_messaging_system.sql` - Database schema updates
- `docker-compose.yml` - Updated with Redis and S3 local stack
- `app/core/websocket.py` - WebSocket connection management

---

## Phase 1 Completion Summary

**Status**: ✅ **COMPLETED** (95% complete)

**Completed Features**:
- ✅ Enhanced camera with video recording, filters, and editing
- ✅ Real-time messaging system with disappearing messages
- ✅ Stories feature with privacy controls and viewing
- ✅ Complete friend management system
- ✅ File storage and media management
- ✅ WebSocket-based real-time communication
- ✅ Comprehensive database schema and API endpoints

**Remaining Tasks**:
- [ ] CDN integration for faster media delivery (optional enhancement)

**Implementation Results**:
- All core MVP functionality is working
- Real-time messaging performs smoothly
- Camera and media features are fully functional
- Friend and story systems are complete
- Database and API architecture is robust

---

## Next Phase Preview

Phase 2 will enhance the MVP with plant-specific features:
- Plant identification using AI
- RAG-powered plant care recommendations
- Plant-focused AR filters and effects
- Community features for plant enthusiasts
- Personalized content discovery

The core MVP provides the solid foundation needed for these advanced AI-enhanced features.