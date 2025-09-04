/**
 * Core TypeScript type definitions for LeafWise application
 * Contains shared types used across multiple features and modules
 * Follows AI-first development principles with clear, descriptive interfaces
 */

// Base entity interface for all data models
export interface BaseEntity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}

// API response wrapper interface
export interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
  error?: string;
}

// Pagination interface for list responses
export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

// Location interface for geographic data
export interface Location {
  latitude: number;
  longitude: number;
  accuracy?: number;
  timestamp?: Date;
}

// Image interface for photo data
export interface ImageData {
  uri: string;
  width: number;
  height: number;
  size?: number;
  mimeType?: string;
}

// Error interface for consistent error handling
export interface AppError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  timestamp: string;
  recoverable: boolean;
}

// Loading state interface
export interface LoadingState {
  isLoading: boolean;
  error?: AppError;
}