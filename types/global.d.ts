/**
 * Global type declarations for LeafWise
 * Extends global namespace with test utilities and other global types
 */

// Test utilities global interface
interface TestUtils {
  mockUser: {
    id: string;
    email: string;
    displayName: string;
  };
  mockPlant: {
    id: string;
    scientificName: string;
    commonName: string;
    family: string;
    confidence: number;
  };
  mockImage: {
    uri: string;
    width: number;
    height: number;
    type: string;
  };
}

// Extend global namespace
declare global {
  var testUtils: TestUtils;
  var __DEV__: boolean;
  
  namespace NodeJS {
    interface Global {
      testUtils: TestUtils;
      __DEV__: boolean;
    }
  }
}

// Export empty object to make this a module
export {};