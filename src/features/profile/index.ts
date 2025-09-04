/**
 * Profile Feature Index
 * Exports all profile-related components, hooks, and services
 */

// Components
export { ProfileEditor } from './components/ProfileEditor';
export { ProfileProvider, useProfileContext } from './components/ProfileProvider';
export { default as ProfileStatistics } from './components/ProfileStatistics';
export { AccountDeletion } from './components/AccountDeletion';

// Hooks
export { useProfile } from './hooks/useProfile';

// Screens
export { ProfileScreen } from './screens/ProfileScreen';

// Services
export { profileService } from './services/ProfileService';

// Types
export * from './types';