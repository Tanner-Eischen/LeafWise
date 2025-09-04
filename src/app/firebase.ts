/**
 * Firebase Configuration and Initialization
 * Centralizes Firebase setup for the LeafWise application
 */

import firebase from '@react-native-firebase/app';
import { getEnvironmentConfig, getCurrentEnvironment } from '../../config/environment';

/**
 * Initialize Firebase with the appropriate configuration
 * This should be called before any Firebase services are used
 */
export function initializeFirebase() {
  try {
    // Check if Firebase is already initialized
    try {
      return firebase.app();
    } catch (error) {
      // Firebase not initialized yet, proceed with initialization
      // Use a default configuration for testing if environment variables are not set
      const defaultConfig = {
        apiKey: "AIzaSyABCdefGHIjklMNOPqrsTUVwxyz12345678",
        authDomain: "LeafWise-dev.firebaseapp.com",
        projectId: "LeafWise-dev",
        storageBucket: "LeafWise-dev.appspot.com",
        messagingSenderId: "123456789",
        appId: "1:123456789:web:abcdef123456"
      };
      
      // Try to get environment config, fall back to default if it fails
      let firebaseConfig;
      try {
        const environment = getCurrentEnvironment();
        const config = getEnvironmentConfig(environment);
        firebaseConfig = config.firebaseConfig;
        
        // Check if any of the required fields are empty
        const hasEmptyValues = Object.values(firebaseConfig).some(value => !value);
        if (hasEmptyValues) {
          console.warn('Firebase config has empty values, using default config');
          firebaseConfig = defaultConfig;
        }
      } catch (configError) {
        console.warn('Failed to get environment config, using default config', configError);
        firebaseConfig = defaultConfig;
      }
      
      console.log('Initializing Firebase with config:', JSON.stringify(firebaseConfig));
      return firebase.initializeApp(firebaseConfig);
    }
  } catch (error) {
    console.error('Failed to initialize Firebase:', error);
    throw error;
  }
}

// Export a pre-initialized Firebase instance
export const firebaseApp = initializeFirebase();