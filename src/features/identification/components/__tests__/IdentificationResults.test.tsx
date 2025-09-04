/**
 * Tests for IdentificationResults component
 * Verifies rendering of loading, error, and results states
 */

import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import IdentificationResults from '../IdentificationResults';
import { PlantInfo, PlantIdError } from '../../../../core/types/plantIdentification';

// Mock data for testing
const mockPlants: PlantInfo[] = [
  {
    scientificName: 'Monstera deliciosa',
    commonNames: ['Swiss Cheese Plant', 'Split-leaf Philodendron'],
    family: 'Araceae',
    genus: 'Monstera',
    confidence: 0.92,
    description: 'Tropical plant with large, perforated leaves',
    imageUrl: 'https://example.com/monstera.jpg',
    careInfo: {
      watering: 'Moderate',
      lightRequirements: 'Bright indirect light',
      growthRate: 'Fast',
    },
  },
  {
    scientificName: 'Ficus lyrata',
    commonNames: ['Fiddle Leaf Fig'],
    family: 'Moraceae',
    genus: 'Ficus',
    confidence: 0.78,
    imageUrl: 'https://example.com/ficus.jpg',
    careInfo: {
      watering: 'Allow to dry between waterings',
      lightRequirements: 'Bright indirect light',
    },
  },
];

const mockError: PlantIdError = {
  code: 'IDENTIFICATION_FAILED',
  message: 'Unable to identify plant from image',
  timestamp: new Date().toISOString(),
  recoverable: true
};

describe('IdentificationResults', () => {
  it('renders loading state correctly', () => {
    const { getByText, getByTestId } = render(
      <IdentificationResults
        isLoading={true}
        plants={[]}
        confidence={0}
        error={null}
      />
    );
    
    expect(getByText('Identifying plant...')).toBeTruthy();
  });
  
  it('renders error state correctly', () => {
    const mockRetry = jest.fn();
    const { getByText } = render(
      <IdentificationResults
        isLoading={false}
        plants={[]}
        confidence={0}
        error={mockError}
        onRetry={mockRetry}
      />
    );
    
    expect(getByText('Identification Failed')).toBeTruthy();
    expect(getByText('Unable to identify plant from image')).toBeTruthy();
    
    // Test retry button
    fireEvent.press(getByText('Try Again'));
    expect(mockRetry).toHaveBeenCalledTimes(1);
  });
  
  it('renders empty state correctly', () => {
    const mockRetry = jest.fn();
    const { getByText } = render(
      <IdentificationResults
        isLoading={false}
        plants={[]}
        confidence={0}
        error={null}
        onRetry={mockRetry}
      />
    );
    
    expect(getByText('No plants identified')).toBeTruthy();
  });
  
  it('renders plant results correctly', () => {
    const mockSelectPlant = jest.fn();
    const { getByText, getAllByText } = render(
      <IdentificationResults
        isLoading={false}
        plants={mockPlants}
        confidence={0.92}
        error={null}
        onSelectPlant={mockSelectPlant}
      />
    );
    
    // Check title
    expect(getByText('Identification Results')).toBeTruthy();
    
    // Check first plant details
    expect(getByText('Monstera deliciosa')).toBeTruthy();
    expect(getByText('Swiss Cheese Plant, Split-leaf Philodendron')).toBeTruthy();
    expect(getByText('92%')).toBeTruthy();
    expect(getByText('Family: Araceae')).toBeTruthy();
    expect(getByText('Genus: Monstera')).toBeTruthy();
    expect(getByText('Water: Moderate')).toBeTruthy();
    expect(getByText('Light: Bright indirect light')).toBeTruthy();
    
    // Check second plant details
    expect(getByText('Ficus lyrata')).toBeTruthy();
    expect(getByText('Fiddle Leaf Fig')).toBeTruthy();
    expect(getByText('78%')).toBeTruthy();
    
    // Test plant selection
    fireEvent.press(getByText('Monstera deliciosa'));
    expect(mockSelectPlant).toHaveBeenCalledWith(mockPlants[0]);
  });
  
  it('handles missing plant data gracefully', () => {
    const minimalPlant: PlantInfo = {
      scientificName: 'Unknown Species',
      commonNames: [],
      confidence: 0.3,
    };
    
    const { getByText, queryByText } = render(
      <IdentificationResults
        isLoading={false}
        plants={[minimalPlant]}
        confidence={0.3}
        error={null}
      />
    );
    
    expect(getByText('Unknown Species')).toBeTruthy();
    expect(getByText('30%')).toBeTruthy();
    
    // These elements should not be present
    expect(queryByText('Family:')).toBeNull();
    expect(queryByText('Genus:')).toBeNull();
    expect(queryByText('Water:')).toBeNull();
    expect(queryByText('Light:')).toBeNull();
  });
});