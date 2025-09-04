/**
 * Navigation types for LeafWise application
 * Defines type definitions for navigation structure
 */

import { NavigatorScreenParams } from '@react-navigation/native';

/**
 * Authentication stack parameter list
 * Defines screens in the authentication flow
 */
export type AuthStackParamList = {
  Login: undefined;
  Register: undefined;
  PasswordReset: { email?: string };
};

/**
 * Collection stack parameter list
 * Defines screens in the collection feature
 */
export type CollectionStackParamList = {
  CollectionGrid: undefined;
  PlantDetail: { plantId: string };
};

/**
 * Identification stack parameter list
 * Defines screens in the identification feature
 */
export type IdentificationStackParamList = {
  IdentificationResults: { imageUri: string };
  IdentificationWithAlternatives: { identificationId: string };
  AlternativeMatches: { identificationId: string };
};

/**
 * Main tab parameter list
 * Defines tabs in the main application
 */
export type MainTabParamList = {
  Collection: NavigatorScreenParams<CollectionStackParamList>;
  Identify: NavigatorScreenParams<IdentificationStackParamList>;
  Profile: undefined;
};

/**
 * Root stack parameter list
 * Defines the top-level navigation structure
 */
export type RootStackParamList = {
  Auth: NavigatorScreenParams<AuthStackParamList>;
  Main: NavigatorScreenParams<MainTabParamList>;
};