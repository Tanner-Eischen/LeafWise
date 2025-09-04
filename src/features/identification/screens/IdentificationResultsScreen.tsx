/**
 * IdentificationResultsScreen
 * Screen component that demonstrates the IdentificationResults component
 * with sample data for development and testing purposes
 */

import React, { useState } from 'react';
import { View, StyleSheet, Button } from 'react-native';
import { IdentificationResults } from '../components';
import { PlantInfo, PlantIdError } from '../../../core/types/plantIdentification';

// Sample data for demonstration
const samplePlants: PlantInfo[] = [
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
      edibleParts: ['Ripe fruit'],
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
  {
    scientificName: 'Sansevieria trifasciata',
    commonNames: ['Snake Plant', 'Mother-in-law\'s Tongue'],
    family: 'Asparagaceae',
    genus: 'Sansevieria',
    confidence: 0.65,
    imageUrl: 'https://example.com/sansevieria.jpg',
    careInfo: {
      watering: 'Low',
      lightRequirements: 'Low to bright indirect light',
      growthRate: 'Slow',
    },
  },
];

const sampleError: PlantIdError = {
  code: 'IDENTIFICATION_FAILED',
  message: 'Unable to identify plant from image. Please try again with a clearer photo.',
  timestamp: new Date().toISOString(),
  recoverable: true
};

/**
 * Demo screen for IdentificationResults component
 * Allows toggling between different states (loading, results, error, empty)
 * 
 * @returns {JSX.Element} Rendered component
 */
function IdentificationResultsScreen(): JSX.Element {
  // State to control which view to display
  const [viewState, setViewState] = useState<'loading' | 'results' | 'error' | 'empty'>('results');
  
  // Handle plant selection
  const handleSelectPlant = (plant: PlantInfo) => {
    console.log('Selected plant:', plant.scientificName);
    // In a real app, this would navigate to a detailed view
  };
  
  // Handle retry action
  const handleRetry = () => {
    setViewState('loading');
    // Simulate loading
    setTimeout(() => setViewState('results'), 1500);
  };
  
  return (
    <View style={styles.container}>
      <View style={styles.demoControls}>
        <Button title="Show Loading" onPress={() => setViewState('loading')} />
        <Button title="Show Results" onPress={() => setViewState('results')} />
        <Button title="Show Error" onPress={() => setViewState('error')} />
        <Button title="Show Empty" onPress={() => setViewState('empty')} />
      </View>
      
      <View style={styles.resultsContainer}>
        <IdentificationResults
          isLoading={viewState === 'loading'}
          plants={viewState === 'results' ? samplePlants : []}
          confidence={viewState === 'results' ? 0.92 : 0}
          error={viewState === 'error' ? sampleError : null}
          onRetry={handleRetry}
          onSelectPlant={handleSelectPlant}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f8f0',
  },
  demoControls: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 10,
    backgroundColor: '#e0f0e0',
  },
  resultsContainer: {
    flex: 1,
  },
});

export default IdentificationResultsScreen;