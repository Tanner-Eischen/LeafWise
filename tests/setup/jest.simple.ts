/**
 * Simple Jest Setup Configuration for LeafWise
 * Minimal setup for basic testing without external dependencies
 */

// Mock React Native modules
jest.mock('react-native', () => {
  const RN = {
    Platform: {
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
      openURL: jest.fn(() => Promise.resolve(true)),
      canOpenURL: jest.fn(() => Promise.resolve(true)),
      openSettings: jest.fn(() => Promise.resolve(true)),
    },
    StyleSheet: {
      create: jest.fn((styles) => styles),
    },
    View: 'View',
    Text: 'Text',
    TouchableOpacity: 'TouchableOpacity',
    ScrollView: 'ScrollView',
  };
  
  return RN;
});

// Mock console methods in tests
(global as any).console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};

// Increase timeout for async operations
jest.setTimeout(10000);