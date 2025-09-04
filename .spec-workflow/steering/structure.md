# Codebase Structure - LeafWise

**Purpose**: This document outlines the organization, structure, and naming conventions for the LeafWise codebase.

## Directory Structure

### Root Level Organization

```
LeafWise/
├── src/                  # Source code
├── assets/               # Static assets (images, fonts)
├── tests/                # Test files
├── docs/                 # Documentation
├── config/               # Configuration files
├── scripts/              # Build and utility scripts
└── [platform-specific]   # iOS/Android specific files
```

### Source Code Organization

```
src/
├── app/                  # App initialization and entry points
│   ├── App.tsx           # Main application component
│   ├── AppProviders.tsx  # Global providers wrapper
│   └── navigation/        # Navigation configuration
│
├── features/             # Feature modules (domain-based)
│   ├── auth/             # Authentication feature
│   ├── camera/           # Camera and photo capture
│   ├── identification/   # Plant identification
│   ├── collection/       # User's plant collection
│   ├── social/           # Social features
│   └── care/             # Plant care and recommendations
│
├── core/                 # Core application code
│   ├── api/              # API client and service interfaces
│   ├── hooks/            # Shared React hooks
│   ├── state/            # Global state management
│   ├── utils/            # Utility functions
│   └── types/            # TypeScript type definitions
│
├── services/             # Service implementations
│   ├── api.service.ts    # API service implementation
│   ├── auth.service.ts   # Authentication service
│   ├── storage.service.ts # Local storage service
│   └── analytics.service.ts # Analytics and tracking
│
└── ui/                   # UI components and styling
    ├── components/       # Shared UI components
    ├── screens/          # Screen components
    ├── theme/            # Theme configuration
    ├── icons/            # Custom icon components
    └── styles/           # Global styles and constants
```

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

### Component Structure

Components follow a consistent organization pattern:

```
components/[ComponentName]/
├── [ComponentName].tsx   # Component implementation
├── [ComponentName].test.tsx # Component tests
├── [ComponentName].styles.ts # Component styles
└── index.ts             # Export file
```

## Naming Conventions

### Files and Directories

- **Directories**: lowercase-kebab-case
- **Component Files**: PascalCase.tsx
- **Utility Files**: camelCase.ts
- **Test Files**: [FileName].test.ts(x)
- **Type Files**: [name].types.ts
- **Hook Files**: use[HookName].ts

### Code Elements

- **Components**: PascalCase (e.g., `PlantCard`)
- **Functions**: camelCase (e.g., `identifyPlant`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_IMAGE_SIZE`)
- **Interfaces/Types**: PascalCase with prefix (e.g., `IUser`, `TPlantData`)
- **Redux Actions**: domain/action format (e.g., `plants/addPlant`)

## Module Organization

### Core Modules

#### API Module

Centralized API client with service-specific implementations:

```typescript
// core/api/client.ts - Base API client
// core/api/endpoints.ts - API endpoint definitions
// features/[feature]/api/[feature].api.ts - Feature-specific API methods
```

#### State Management

Redux store with feature-based slices:

```typescript
// core/state/store.ts - Redux store configuration
// features/[feature]/state/[feature].slice.ts - Feature state slice
// features/[feature]/state/[feature].selectors.ts - Feature state selectors
```

#### Navigation

React Navigation with feature-based organization:

```typescript
// app/navigation/AppNavigator.tsx - Main navigation container
// app/navigation/[StackName]Navigator.tsx - Stack navigators
// features/[feature]/navigation/routes.ts - Feature routes
```

## Code Organization Principles

### Separation of Concerns

- **Presentation Logic**: Components focus on rendering and user interaction
- **Business Logic**: Hooks and services handle business rules and data processing
- **Data Access**: API services handle data fetching and persistence
- **State Management**: Redux/Context for global state, local state for component-specific concerns

### Feature Isolation

- Features should be self-contained with minimal dependencies on other features
- Cross-feature communication happens through core state or services
- Features export a clear public API through their index.ts file

### Code Splitting Strategy

- Split code along feature boundaries for efficient loading
- Lazy-load non-critical features and screens
- Keep critical path code minimal and optimized

## Import/Export Patterns

### Barrel Exports

Use index files to simplify imports:

```typescript
// features/plants/index.ts
export * from './components';
export * from './screens';
export * from './hooks';
// Only export what should be public API
```

### Import Organization

Standardized import ordering:

```typescript
// 1. External libraries
import React from 'react';
import { View, Text } from 'react-native';

// 2. Core/app imports
import { useAppDispatch } from 'core/hooks';

// 3. Feature imports from other features
import { UserAvatar } from 'features/user';

// 4. Current feature imports
import { usePlantData } from '../hooks';
import { PlantImage } from './PlantImage';

// 5. Style imports
import { styles } from './styles';
```

## File Size Guidelines

- **Maximum File Size**: 500 lines (for AI compatibility)
- **Component Files**: Aim for <200 lines, extract as needed
- **Utility Files**: Group related functions, but keep under limit