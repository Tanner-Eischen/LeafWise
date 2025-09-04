/**
 * Authentication Services Index
 * Exports the authentication service interface and implementation
 * Provides a service provider for dependency injection
 */

import { IAuthService } from '../types';
import { AuthService, authService } from './AuthService';

// Export interfaces and implementations
export { IAuthService, AuthService, authService };

/**
 * Register authentication services with the application
 * This function should be called during application initialization
 * 
 * @param {Object} container - The dependency injection container
 * @param {Object} config - Optional configuration for services
 */
export function registerAuthServices(container: any, config?: any): void {
  // Register the authentication service
  container.register('authService', {
    useValue: authService
  });
}