/**
 * Jest Setup Configuration for LeafWise
 * Global test setup, mocks, and utilities
 */

import 'react-native-gesture-handler/jestSetup';
import mockAsyncStorage from '@react-native-async-storage/async-storage/jest/async-storage-mock';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => mockAsyncStorage);

// Mock React Native modules
jest.mock('react-native', () => {
  const RN = jest.requireActual('react-native');
  
  return {
    ...RN,
    Platform: {
      ...RN.Platform,
      OS: 'ios',
      select: jest.fn((obj) => obj.ios),
    },
    Dimensions: {
      get: jest.fn(() => ({ width: 375, height: 812 })),
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
    },
    Alert: {
      alert: jest.fn(),
    },
    Linking: {
      openURL: jest.fn(),
      canOpenURL: jest.fn(() => Promise.resolve(true)),
    },
  };
});

// Mock Expo modules
jest.mock('expo-constants', () => ({
  default: {
    expoConfig: {
      name: 'LeafWise Test',
      slug: 'LeafWise-test',
    },
  },
}));

jest.mock('expo-status-bar', () => ({
  StatusBar: 'StatusBar',
}));

// Mock Camera module
jest.mock('expo-camera', () => ({
  Camera: {
    requestCameraPermissionsAsync: jest.fn(() => 
      Promise.resolve({ status: 'granted' })
    ),
    getCameraPermissionsAsync: jest.fn(() => 
      Promise.resolve({ status: 'granted' })
    ),
  },
  CameraType: {
    back: 'back',
    front: 'front',
  },
}));

// Mock Image Picker
jest.mock('expo-image-picker', () => ({
  requestMediaLibraryPermissionsAsync: jest.fn(() => 
    Promise.resolve({ status: 'granted' })
  ),
  launchImageLibraryAsync: jest.fn(() => 
    Promise.resolve({
      cancelled: false,
      assets: [{
        uri: 'mock-image-uri',
        width: 100,
        height: 100,
      }],
    })
  ),
}));

// Mock Firebase
jest.mock('@react-native-firebase/app', () => ({
  default: {
    apps: [],
    initializeApp: jest.fn(),
  },
}));

jest.mock('@react-native-firebase/auth', () => ({
  default: () => ({
    signInWithEmailAndPassword: jest.fn(() => Promise.resolve()),
    createUserWithEmailAndPassword: jest.fn(() => Promise.resolve()),
    signOut: jest.fn(() => Promise.resolve()),
    onAuthStateChanged: jest.fn(),
    currentUser: null,
  }),
}));

// Mock Network requests
(global as any).fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    status: 200,
    json: () => Promise.resolve({}),
    text: () => Promise.resolve(''),
  })
) as jest.Mock;

// Mock console methods in tests
(global as any).console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};

// Global test utilities
(global as any).testUtils = {
  // Mock user data
  mockUser: {
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
  },
  
  // Mock plant data
  mockPlant: {
    id: 'test-plant-id',
    scientificName: 'Rosa rubiginosa',
    commonName: 'Sweet Briar',
    family: 'Rosaceae',
    confidence: 0.95,
  },
  
  // Mock image data
  mockImage: {
    uri: 'mock-image-uri',
    width: 100,
    height: 100,
    type: 'image/jpeg',
  },
};

// Increase timeout for async operations
jest.setTimeout(10000);

// Suppress specific warnings in tests
const originalWarn = console.warn;
console.warn = (...args) => {
  if (
    typeof args[0] === 'string' &&
    args[0].includes('Warning: ReactDOM.render is no longer supported')
  ) {
    return;
  }
  originalWarn.call(console, ...args);
};