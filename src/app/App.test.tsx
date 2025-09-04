/**
 * App Component Tests
 * Tests for the main App component functionality
 */

import React from 'react';
import { render, screen } from '@testing-library/react-native';
import App from './App';

// Mock Expo modules for testing
jest.mock('expo-status-bar', () => ({
  StatusBar: () => null,
}));

describe('App Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders without crashing', () => {
    const component = render(<App />);
    expect(component).toBeTruthy();
  });

  it('exports App component properly', () => {
    expect(App).toBeDefined();
    expect(typeof App).toBe('function');
  });
});