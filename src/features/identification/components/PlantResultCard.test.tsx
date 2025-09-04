/**
 * Tests for PlantResultCard component
 */

import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import PlantResultCard from './PlantResultCard';
import { PlantInfo } from '../../../core/types/plantIdentification';

// Sample plant data for testing
const samplePlant: PlantInfo = {
  id: '1',
  scientificName: 'Monstera deliciosa',
  commonNames: ['Swiss Cheese Plant', 'Split-leaf Philodendron'],
  family: 'Araceae',
  genus: 'Monstera',
  confidence: 0.85,
  imageUrl: 'https://example.com/monstera.jpg',
  description: 'A popular tropical plant known for its distinctive split leaves.',
  careInfo: {
    watering: 'Medium',
    lightRequirements: 'Bright indirect light',
    soilType: 'Well-draining potting mix',
    fertilization: 'Monthly during growing season',
  },
};

describe('PlantResultCard', () => {
  it('renders correctly with full plant data', () => {
    const { getByText } = render(
      <PlantResultCard plant={samplePlant} />
    );
    
    expect(getByText('Monstera deliciosa')).toBeTruthy();
    expect(getByText('Swiss Cheese Plant')).toBeTruthy();
    expect(getByText('Family: Araceae')).toBeTruthy();
    expect(getByText('Genus: Monstera')).toBeTruthy();
  });
  
  it('renders correctly in compact mode', () => {
    const { getByText, queryByText } = render(
      <PlantResultCard plant={samplePlant} compact={true} />
    );
    
    expect(getByText('Monstera deliciosa')).toBeTruthy();
    expect(getByText('Swiss Cheese Plant')).toBeTruthy();
    
    // Taxonomy info should not be visible in compact mode
    expect(queryByText('Family: Araceae')).toBeNull();
    expect(queryByText('Genus: Monstera')).toBeNull();
  });
  
  it('handles missing common names', () => {
    const plantWithoutCommonNames = {
      ...samplePlant,
      commonNames: [],
    };
    
    const { getByText, queryByText } = render(
      <PlantResultCard plant={plantWithoutCommonNames} />
    );
    
    expect(getByText('Monstera deliciosa')).toBeTruthy();
    expect(queryByText('Swiss Cheese Plant')).toBeNull();
  });
  
  it('handles missing taxonomy info', () => {
    const plantWithoutTaxonomy = {
      ...samplePlant,
      family: undefined,
      genus: undefined,
    };
    
    const { getByText, queryByText } = render(
      <PlantResultCard plant={plantWithoutTaxonomy} />
    );
    
    expect(getByText('Monstera deliciosa')).toBeTruthy();
    expect(queryByText('Family: Araceae')).toBeNull();
    expect(queryByText('Genus: Monstera')).toBeNull();
  });
  
  it('handles missing image URL', () => {
    const plantWithoutImage = {
      ...samplePlant,
      imageUrl: undefined,
    };
    
    const { getByText } = render(
      <PlantResultCard plant={plantWithoutImage} />
    );
    
    expect(getByText('No Image')).toBeTruthy();
  });
  
  it('calls onPress callback when pressed', () => {
    const onPressMock = jest.fn();
    
    const { getByText } = render(
      <PlantResultCard plant={samplePlant} onPress={onPressMock} />
    );
    
    fireEvent.press(getByText('Monstera deliciosa'));
    expect(onPressMock).toHaveBeenCalledTimes(1);
  });
});