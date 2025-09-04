/**
 * Identification Services Index
 * Exports the plant identification service interface and implementation
 * Provides a service provider for dependency injection
 */

import { IPlantIdentificationService } from './IPlantIdentificationService';
import { PlantIdentificationService, plantIdentificationService } from './PlantIdentificationService';

// Export interfaces and implementations
export { IPlantIdentificationService, PlantIdentificationService, plantIdentificationService };

/**
 * Register identification services with the application
 * This function should be called during application initialization
 * 
 * @param {Object} container - The dependency injection container
 * @param {Object} config - Optional configuration for services
 */
export function registerIdentificationServices(container: any, config?: any): void {
  // Register the plant identification service
  container.register('plantIdentificationService', {
    useValue: plantIdentificationService
  });
}