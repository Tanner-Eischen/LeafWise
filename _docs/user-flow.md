# User Flow Documentation

This document defines the complete user journey through our plant-focused Snapchat clone with RAG enhancements, targeting general users aged 20-30 with a focus on plant enthusiasts and gardeners of all levels.

---

## User Personas

**Primary Target**: Plant enthusiasts and gardeners (20-30 years old)
- Beginner gardeners seeking advice and inspiration
- Experienced plant parents sharing knowledge
- Urban gardeners with limited space
- Plant collectors showcasing rare finds
- Garden designers and landscapers

---

## Core User Journey

### 1. Onboarding & Authentication

**Entry Point**: App launch (first time)

1. **Welcome Screen**
   - Brief app introduction highlighting plant community focus
   - "Get Started" CTA

2. **Email Registration**
   - Email input and password creation
   - Plant interest selection (houseplants, outdoor gardening, succulents, etc.)
   - Experience level selection (beginner, intermediate, expert)

3. **Profile Setup**
   - Username creation
   - Profile photo upload
   - Bio with gardening interests
   - Location (for local plant community connections)

4. **Permission Requests**
   - Camera access for plant photos
   - Contacts access for friend discovery
   - Location for local gardening communities

### 2. Main Navigation Structure

**Bottom Tab Navigation**:
- **Camera** (Center, primary action)
- **Chat** (Messages)
- **Discover** (Content discovery with RAG)
- **Stories** (Friend stories)
- **Profile** (User profile)

### 3. Content Creation Flow

**Camera Tab (Primary Entry)**:

1. **Camera Interface**
   - Photo/video toggle
   - Plant-specific AR filters (growth time-lapse, plant identification overlay)
   - Swipe gestures to access filters

2. **Content Capture**
   - Tap to capture photo
   - Hold for video recording
   - Plant identification suggestions via RAG

3. **Content Enhancement**
   - **RAG-Generated Captions**: AI suggests plant-specific captions based on identified species
   - **Care Tips Integration**: Automatic care reminders and tips overlay
   - **Filter Application**: Plant health filters, growth progression effects

4. **Sharing Options**
   - Send to specific friends (disappearing message)
   - Add to My Story
   - Post to plant community groups
   - Save to plant journal (persistent)

### 4. Discovery & RAG Integration

**Discover Tab Flow**:

1. **Personalized Feed**
   - RAG-curated content based on user's plant interests
   - Seasonal gardening tips
   - Local plant community highlights

2. **Search Functions**
   - Plant species search with AI identification
   - Care guide lookup
   - Local nursery and garden center finder
   - Expert gardener discovery

3. **RAG-Enhanced Recommendations**
   - **Content Suggestions**: "Plants similar to your collection"
   - **Friend Recommendations**: Connect with local gardeners
   - **Learning Paths**: Beginner to expert gardening guides
   - **Seasonal Content**: "Plants to start this month"

### 5. Social Features Flow

**Friend Management**:

1. **Friend Discovery**
   - Username search for known gardeners
   - Phone contacts integration
   - Local gardener suggestions via location
   - Plant interest-based recommendations

2. **Connection Process**
   - Send friend request
   - Accept/decline incoming requests
   - Follow public plant accounts

**Messaging Experience**:

1. **Chat Tab Navigation**
   - Recent conversations list
   - Group chats for plant communities
   - Direct messages with disappearing content

2. **Message Types**
   - Photo/video with plant care questions
   - Voice messages for plant identification help
   - Location sharing for garden visits
   - Plant care reminders and tips

3. **Disappearing Content**
   - Standard messages disappear after viewing
   - Plant care tips can be saved to personal journal
   - No notification when content disappears

### 6. Stories & Community Features

**Stories Tab Flow**:

1. **Story Viewing**
   - Friend stories in chronological order
   - Plant community highlights
   - Local garden events and workshops

2. **Story Creation**
   - Add to personal story
   - Contribute to community plant challenges
   - Share garden progress updates

3. **Interactive Elements**
   - Plant identification polls
   - Care tip sharing
   - Before/after plant transformations

### 7. RAG-Enhanced Features Throughout Journey

**Contextual AI Integration**:

1. **Smart Captions**
   - Auto-generated plant care captions
   - Species identification with care tips
   - Seasonal growing advice

2. **Personalized Content**
   - Feed curated based on plant collection
   - Care reminders for user's specific plants
   - Local growing condition adjustments

3. **Learning Recommendations**
   - Progressive skill-building content
   - Expert advice matching user's experience level
   - Problem-solving guides for plant issues

4. **Community Connections**
   - Local gardener introductions
   - Plant swap opportunity alerts
   - Garden event recommendations

---

## Key User Flows

### Flow A: New Plant Parent Seeking Help
1. Open camera → Capture struggling plant photo
2. RAG identifies plant and suggests care tips
3. Share to plant expert friends for advice
4. Receive disappearing video responses with solutions
5. Save helpful tips to plant journal

### Flow B: Experienced Gardener Sharing Knowledge
1. Navigate to Discover → See beginner questions
2. Create helpful response video with care demonstration
3. Use plant-specific AR filters for educational overlay
4. Share to community story for broader reach
5. Connect with new gardeners seeking mentorship

### Flow C: Seasonal Garden Planning
1. Open Discover → View RAG-curated seasonal content
2. Explore "Plants to start this month" recommendations
3. Save interesting plants to wishlist
4. Share planning ideas with gardening friends
5. Create story documenting garden planning process

---

## Success Metrics

- **Engagement**: Daily active users sharing plant content
- **Community Growth**: New connections between plant enthusiasts
- **Knowledge Sharing**: Care tips and advice exchanges
- **RAG Effectiveness**: Accuracy of plant identification and recommendations
- **User Retention**: Return visits for seasonal gardening guidance

---

## Technical Considerations

- **RAG Data Sources**: Plant databases, care guides, local growing conditions
- **AR Filter Requirements**: Plant identification, growth visualization
- **Content Moderation**: Plant-focused community guidelines
- **Offline Capabilities**: Basic plant identification and care tips
- **Performance**: Fast plant identification and recommendation loading

This user flow serves as the foundation for our plant-focused social platform, ensuring every feature connects meaningfully to enhance the gardening community experience.