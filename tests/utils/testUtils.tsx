/**
 * Test Utilities for LeafWise
 * Common testing helpers, custom render functions, and mock factories
 */

import React, { ReactElement } from 'react';
import { render, RenderOptions } from '@testing-library/react-native';
import { NavigationContainer } from '@react-navigation/native';

// Mock providers for testing
interface TestProvidersProps {
  children: React.ReactNode;
}

/**
 * Test wrapper component that provides necessary context providers
 * @param children - Child components to wrap
 */
function TestProviders({ children }: TestProvidersProps) {
  return (
    <NavigationContainer>
      {children}
    </NavigationContainer>
  );
}

/**
 * Custom render function with providers
 * @param ui - Component to render
 * @param options - Render options
 * @returns Render result with providers
 */
function customRender(
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) {
  return render(ui, { wrapper: TestProviders, ...options });
}

/**
 * Creates a mock navigation object for testing
 * @returns Mock navigation object
 */
function createMockNavigation() {
  return {
    navigate: jest.fn(),
    goBack: jest.fn(),
    dispatch: jest.fn(),
    setParams: jest.fn(),
    addListener: jest.fn(),
    removeListener: jest.fn(),
    canGoBack: jest.fn(() => true),
    isFocused: jest.fn(() => true),
    push: jest.fn(),
    replace: jest.fn(),
    pop: jest.fn(),
    popToTop: jest.fn(),
    reset: jest.fn(),
    setOptions: jest.fn(),
    getParent: jest.fn(),
    getId: jest.fn(),
    getState: jest.fn(),
  };
}

/**
 * Creates a mock route object for testing
 * @param params - Route parameters
 * @returns Mock route object
 */
function createMockRoute(params = {}) {
  return {
    key: 'test-route-key',
    name: 'TestScreen',
    params,
    path: undefined,
  };
}

/**
 * Mock factory for user data
 * @param overrides - Properties to override
 * @returns Mock user object
 */
function createMockUser(overrides = {}) {
  return {
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    profilePicture: null,
    createdAt: new Date().toISOString(),
    ...overrides,
  };
}

/**
 * Mock factory for plant data
 * @param overrides - Properties to override
 * @returns Mock plant object
 */
function createMockPlant(overrides = {}) {
  return {
    id: 'test-plant-id',
    scientificName: 'Rosa rubiginosa',
    commonName: 'Sweet Briar',
    family: 'Rosaceae',
    imageUrl: 'https://example.com/plant.jpg',
    confidence: 0.95,
    identifiedAt: new Date().toISOString(),
    userId: 'test-user-id',
    location: {
      latitude: 40.7128,
      longitude: -74.0060,
    },
    basicInfo: 'A thorny shrub with fragrant pink flowers.',
    ...overrides,
  };
}

/**
 * Mock factory for identification results
 * @param overrides - Properties to override
 * @returns Mock identification result
 */
function createMockIdentificationResult(overrides = {}) {
  return {
    suggestions: [
      {
        id: 'suggestion-1',
        plant_name: 'Rosa rubiginosa',
        plant_details: {
          common_names: ['Sweet Briar', 'Eglantine'],
          structured_name: {
            genus: 'Rosa',
            species: 'rubiginosa',
          },
        },
        probability: 0.95,
      },
    ],
    modifiers: [],
    secret: 'test-secret',
    fail_cause: null,
    countable: true,
    feedback: null,
    is_plant_probability: 0.98,
    ...overrides,
  };
}

/**
 * Mock factory for API responses
 * @param data - Response data
 * @param status - HTTP status code
 * @returns Mock API response
 */
function createMockApiResponse(data: any, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    statusText: status === 200 ? 'OK' : 'Error',
    json: () => Promise.resolve(data),
    text: () => Promise.resolve(JSON.stringify(data)),
    headers: new Headers(),
  };
}

/**
 * Waits for a specified amount of time
 * @param ms - Milliseconds to wait
 * @returns Promise that resolves after the specified time
 */
function wait(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Waits for the next tick in the event loop
 * @returns Promise that resolves on next tick
 */
function waitForNextTick() {
  return new Promise<void>(resolve => setImmediate(() => resolve()));
}

// Re-export everything from testing library
export * from '@testing-library/react-native';

// Export custom utilities
export {
  customRender as render,
  createMockNavigation,
  createMockRoute,
  createMockUser,
  createMockPlant,
  createMockIdentificationResult,
  createMockApiResponse,
  wait,
  waitForNextTick,
};