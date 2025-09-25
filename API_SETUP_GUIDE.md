# LeafWise API Configuration Guide

## 🚨 IMPORTANT: Required API Keys Setup

Your LeafWise application is fully implemented but requires proper API key configuration to function correctly. The features you're looking for (telemetry, AR overlays, AI integration) are all implemented but currently using placeholder API keys.

## Current Issues

1. **AI Features Not Working**: OpenAI API key is set to placeholder value
2. **Weather Features Limited**: Weather API keys are placeholder values
3. **Authentication Errors**: Some 401 errors due to missing authentication tokens

## Required API Keys

### 1. OpenAI API Key (CRITICAL - Required for AI features)

**What it enables:**
- Plant identification using AI vision
- Content generation and recommendations
- RAG (Retrieval Augmented Generation) functionality
- Embedding generation for semantic search

**How to get it:**
1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Create an account or sign in
3. Generate a new API key
4. Copy the key (starts with `sk-`)

**Where to set it:**
In `backend/.env`, replace:
```
OPENAI_API_KEY=sk-your-actual-openai-api-key-here
```

### 2. Weather API Keys (OPTIONAL - Enhances seasonal features)

**OpenWeatherMap API:**
1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for free account
3. Get your API key from dashboard

**WeatherAPI:**
1. Go to [WeatherAPI](https://www.weatherapi.com/)
2. Sign up for free account
3. Get your API key

**Where to set them:**
In `backend/.env`, replace:
```
OPENWEATHERMAP_API_KEY=your-actual-openweathermap-api-key-here
WEATHERAPI_KEY=your-actual-weatherapi-key-here
```

## Features Currently Available

✅ **Backend API Endpoints:**
- `/api/v1/telemetry/*` - All telemetry endpoints are implemented
- `/api/v1/ml-*` - Machine learning endpoints
- `/api/v1/seasonal-ai/*` - Seasonal AI predictions
- `/api/v1/plant-id/*` - Plant identification
- All other documented endpoints

✅ **Frontend Features:**
- Telemetry data collection and display
- AR camera overlays for plant identification
- Growth tracking and analytics
- Offline-first architecture with sync
- Comprehensive plant management

## After Setting Up API Keys

1. **Restart the backend server:**
   ```bash
   cd backend
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **Test AI features:**
   - Plant identification should work with real AI
   - Content generation should provide real recommendations
   - RAG functionality should work properly

3. **Authentication Setup:**
   - Create a user account through the app
   - Login to get proper authentication tokens
   - This will resolve the 401 errors you're seeing

## Cost Considerations

- **OpenAI API**: Pay-per-use, typically $0.002-0.02 per request depending on model
- **Weather APIs**: Usually have generous free tiers (1000+ requests/day)

## Support

If you continue having issues after setting up the API keys:
1. Check the backend logs for specific error messages
2. Verify the API keys are valid and have sufficient credits
3. Ensure the backend server restarted after changing .env file

The application is fully functional - it just needs proper API configuration!