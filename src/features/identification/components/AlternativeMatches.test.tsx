/**
 * Tests for AlternativeMatches component
 */

import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import AlternativeMatches from './AlternativeMatches';
import { PlantInfo } from '../../../core/types/plantIdentification';

// Mock data for testing
const mockPlants: PlantInfo[] = [
  {
    scientificName: 'Monstera deliciosa',
    commonNames: ['Swiss Cheese Plant', 'Split-leaf Philodendron'],
    family: 'Araceae',
    genus: 'Monstera',
    confidence: 0.92,
    imageUrl: 'https://example.com/monstera.jpg',
    description: 'A popular houseplant with distinctive split leaves.',
    careInfo: {
      watering: 'Medium',
      lightRequirements: 'Bright indirect',
      growthRate: 'Moderate',
      edibleParts: [],
    },
  },
  {
    scientificName: 'Epipremnum aureum',
    commonNames: ['Pothos', 'Devil\'s Ivy'],
    family: 'Araceae',
    genus: 'Epipremnum',
    confidence: 0.78,
    imageUrl: 'https://example.com/pothos.jpg',
    description: 'An easy-to-grow houseplant with heart-shaped leaves.',
    careInfo: {
      watering: 'Low to medium',
      lightRequirements: 'Low to bright indirect',
      growthRate: 'Fast',
      edibleParts: [],
    },
  },
  {
    scientificName: 'Philodendron hederaceum',
    commonNames: ['Heartleaf Philodendron'],
    family: 'Araceae',
    genus: 'Philodendron',
    confidence: 0.65,
    imageUrl: 'https://example.com/philodendron.jpg',
    description: 'A trailing plant with heart-shaped glossy leaves.',
    careInfo: {
      watering: 'Medium',
      lightRequirements: 'Medium to bright indirect',
      growthRate: 'Moderate',
      edibleParts: [],
    },
  },
];

describe('AlternativeMatches', () => {
  const mockOnSelectPlant = jest.fn();

  beforeEach(() => {
    mockOnSelectPlant.mockClear();
  });

  test('renders correctly with multiple plants', () => {
    const { getByText, getAllByText } = render(
      <AlternativeMatches
        plants={mockPlants}
        selectedPlantIndex={0}
        onSelectPlant={mockOnSelectPlant}
      />
    );

    // Check title and subtitle
    expect(getByText('Alternative Matches')).toBeTruthy();
    expect(getByText('Select a different match if the primary identification is incorrect')).toBeTruthy();

    // Check plant names are displayed
    expect(getByText('Monstera deliciosa')).toBeTruthy();
    expect(getByText('Epipremnum aureum')).toBeTruthy();
    expect(getByText('Philodendron hederaceum')).toBeTruthy();

    // Check confidence values are displayed
    expect(getByText('92%')).toBeTruthy();
    expect(getByText('78%')).toBeTruthy();
    expect(getByText('65%')).toBeTruthy();
  });

  test('renders empty state when no plants are provided', () => {
    const { getByText } = render(
      <AlternativeMatches
        plants={[]}
        selectedPlantIndex={0}
        onSelectPlant={mockOnSelectPlant}
      />
    );

    expect(getByText('No alternative matches available')).toBeTruthy();
  });

  test('renders single match message when only one plant is provided', () => {
    const { getByText } = render(
      <AlternativeMatches
        plants={[mockPlants[0]]}
        selectedPlantIndex={0}
        onSelectPlant={mockOnSelectPlant}
      />
    );

    expect(getByText('No alternative matches found')).toBeTruthy();
  });

  test('calls onSelectPlant when a plant is pressed', () => {
    const { getAllByText } = render(
      <AlternativeMatches
        plants={mockPlants}
        selectedPlantIndex={0}
        onSelectPlant={mockOnSelectPlant}
      />
    );

    // Find and press the second plant
    const pothos = getAllByText('Epipremnum aureum')[0];
    fireEvent.press(pothos.parent);

    // Check if onSelectPlant was called with the correct plant and index
    expect(mockOnSelectPlant).toHaveBeenCalledWith(mockPlants[1], 1);
  });

  test('renders detailed view when showDetails is true', () => {
    const { getByText } = render(
      <AlternativeMatches
        plants={mockPlants}
        selectedPlantIndex={0}
        onSelectPlant={mockOnSelectPlant}
        showDetails={true}
      />
    );

    // Check that family and genus information is displayed
    expect(getByText('Family: Araceae')).toBeTruthy();
    expect(getByText('Genus: Monstera')).toBeTruthy();
  });

  test('handles missing image URLs', () => {
    const plantsWithoutImage = [
      {
        ...mockPlants[0],
        imageUrl: undefined,
      },
      ...mockPlants.slice(1),
    ];

    const { getByText } = render(
      <AlternativeMatches
        plants={plantsWithoutImage}
        selectedPlantIndex={0}
        onSelectPlant={mockOnSelectPlant}
      />
    );

    expect(getByText('No image')).toBeTruthy();
  });
});