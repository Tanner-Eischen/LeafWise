# LeafWise - Plant Identification App

A React Native application for plant identification using AI, built with Expo and TypeScript. This project follows AI-first development principles with a modular, scalable architecture.

## 🌱 Project Overview

LeafWise is a mobile application that allows users to identify plants by taking photos. The app includes features for user authentication, plant collection management, and social interactions around plant discovery.

## 🏗️ Project Structure

The project follows a feature-based architecture designed for maintainability and AI compatibility:

```
LeafWise/
├── src/
│   ├── app/                  # App initialization and entry points
│   │   ├── App.tsx           # Main application component
│   │   └── navigation/       # Navigation configuration
│   ├── features/             # Feature modules (domain-based)
│   │   ├── auth/             # Authentication feature
│   │   ├── camera/           # Camera and photo capture
│   │   ├── identification/   # Plant identification
│   │   ├── collection/       # User's plant collection
│   │   ├── social/           # Social features
│   │   └── care/             # Plant care and recommendations
│   ├── core/                 # Core application code
│   │   ├── api/              # API client and service interfaces
│   │   ├── hooks/            # Shared React hooks
│   │   ├── state/            # Global state management
│   │   ├── utils/            # Utility functions
│   │   └── types/            # TypeScript type definitions
│   ├── services/             # Service implementations
│   └── ui/                   # UI components and styling
│       ├── components/       # Shared UI components
│       ├── screens/          # Screen components
│       ├── theme/            # Theme configuration
│       ├── icons/            # Custom icon components
│       └── styles/           # Global styles and constants
├── assets/                   # Static assets (images, fonts)
├── tests/                    # Test files
├── docs/                     # Documentation
├── config/                   # Configuration files
└── scripts/                  # Build and utility scripts
```

## 🚀 Getting Started

### Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Expo CLI
- iOS Simulator (for iOS development)
- Android Studio (for Android development)

### Installation

1. Clone the repository:
   ```bash`
   git clone <repository-url>
   cd LeafWise
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

4. Run on specific platforms:
   ```bash
   npm run android  # Android
   npm run ios      # iOS
   npm run web      # Web
   ```

## 🛠️ Development Scripts

- `npm start` - Start the Expo development server
- `npm run android` - Run on Android device/emulator
- `npm run ios` - Run on iOS device/simulator
- `npm run web` - Run in web browser
- `npm run lint` - Run ESLint code analysis
- `npm run lint:fix` - Fix ESLint issues automatically
- `npm run format` - Format code with Prettier
- `npm run format:check` - Check code formatting
- `npm run type-check` - Run TypeScript type checking

## 📋 Development Guidelines

### Code Style

- **File Size**: Keep files under 500 lines for AI compatibility
- **Single Responsibility**: Each file should have one clear purpose
- **Functional Programming**: Prefer functions over classes
- **TypeScript**: Use strict typing throughout the codebase
- **Documentation**: Include JSDoc comments for all functions

### Naming Conventions

- **Files**: PascalCase for components, camelCase for utilities
- **Directories**: lowercase-kebab-case
- **Variables**: camelCase with descriptive auxiliary verbs (isLoading, hasError)
- **Constants**: UPPER_SNAKE_CASE
- **Components**: PascalCase

### Feature Module Structure

Each feature follows a consistent structure:

```
features/[feature-name]/
├── api/                  # Feature-specific API calls
├── components/           # Feature-specific components
├── hooks/                # Feature-specific hooks
├── screens/              # Feature screens
├── types/                # Feature-specific types
├── utils/                # Feature-specific utilities
└── index.ts             # Public API for the feature
```

## 🎨 Design System

The app uses a nature-inspired design system with:

- **Primary Colors**: Green palette (#4a7c4a and variants)
- **Secondary Colors**: Earth tones for warmth
- **Typography**: Scalable font system
- **Spacing**: 4px grid system
- **Components**: Reusable UI components with consistent styling

## 🧪 Testing

- Unit tests for individual components and utilities
- Integration tests for feature interactions
- End-to-end tests for critical user flows
- Type checking with TypeScript
- Code quality with ESLint and Prettier

## 📱 Platform Support

- **iOS**: iOS 13.0+
- **Android**: Android 6.0+ (API level 23)
- **Web**: Modern browsers with ES2020 support

## 🔧 Configuration

- **TypeScript**: Strict mode enabled
- **ESLint**: Custom rules for React Native and TypeScript
- **Prettier**: Consistent code formatting
- **Expo**: Latest SDK with new architecture support

## 📚 Documentation

- [Project Requirements](../../../_docs/PROJECT_REQUIREMENTS.md)
- [Technical Architecture](../../../_docs/steering/TECHNICAL_ARCHITECTURE.md)
- [Coding Standards](../../../_docs/steering/CODING_STANDARDS.md)
- [Phase 1 Tasks](../../../_docs/phases/phase-1-tasks.md)

## 🤝 Contributing

1. Follow the established code style and structure
2. Write tests for new features
3. Update documentation as needed
4. Use descriptive commit messages
5. Keep files under 500 lines

## 📄 License

This project is licensed under the MIT License.

---

**Phase 1: Foundation Setup - Complete** ✅

The project structure is established with TypeScript, linting, and development tools configured. Ready for feature implementation in subsequent phases.