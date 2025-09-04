/**
 * Theme configuration for LeafWise application
 * Defines colors, typography, spacing, and other design tokens
 * Provides consistent design system across the application
 */

// Color palette inspired by nature and plants
export const colors = {
  // Primary colors (green theme for plant app)
  primary: {
    50: '#f0f9f0',
    100: '#dcf2dc',
    200: '#bae5ba',
    300: '#8dd48d',
    400: '#5cb85c',
    500: '#4a7c4a', // Main brand color
    600: '#3d6b3d',
    700: '#2d5a2d',
    800: '#1e3f1e',
    900: '#0f2f0f',
  },
  
  // Secondary colors (earth tones)
  secondary: {
    50: '#faf8f5',
    100: '#f5f1eb',
    200: '#ebe3d7',
    300: '#ddd0c0',
    400: '#c9b8a4',
    500: '#b5a088',
    600: '#9d8a6f',
    700: '#7d6b56',
    800: '#5d4f42',
    900: '#3d342e',
  },
  
  // Neutral colors
  neutral: {
    50: '#fafafa',
    100: '#f5f5f5',
    200: '#e5e5e5',
    300: '#d4d4d4',
    400: '#a3a3a3',
    500: '#737373',
    600: '#525252',
    700: '#404040',
    800: '#262626',
    900: '#171717',
  },
  
  // Semantic colors
  success: '#22c55e',
  warning: '#f59e0b',
  error: '#ef4444',
  info: '#3b82f6',
  
  // Background colors
  background: {
    primary: '#ffffff',
    secondary: '#f8faf8',
    tertiary: '#f0f8f0',
  },
  
  // Text colors
  text: {
    primary: '#171717',
    secondary: '#525252',
    tertiary: '#737373',
    inverse: '#ffffff',
  },
};

// Typography scale
export const typography = {
  fontSizes: {
    xs: 12,
    sm: 14,
    base: 16,
    lg: 18,
    xl: 20,
    '2xl': 24,
    '3xl': 30,
    '4xl': 36,
    '5xl': 48,
  },
  
  fontWeights: {
    normal: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
  },
  
  lineHeights: {
    tight: 1.25,
    normal: 1.5,
    relaxed: 1.75,
  },
};

// Spacing scale (based on 4px grid)
export const spacing = {
  0: 0,
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
  12: 48,
  16: 64,
  20: 80,
  24: 96,
};

// Border radius values
export const borderRadius = {
  none: 0,
  sm: 4,
  base: 8,
  md: 12,
  lg: 16,
  xl: 24,
  full: 9999,
};

// Shadow definitions
export const shadows = {
  sm: {
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  base: {
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  lg: {
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 4,
  },
};

// Complete theme object
export const theme = {
  colors,
  typography,
  spacing,
  borderRadius,
  shadows,
};

export type Theme = typeof theme;