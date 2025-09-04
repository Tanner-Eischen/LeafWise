/**
 * IdentificationWithAlternativesScreen
 * Demo screen that integrates IdentificationResults with AlternativeMatches
 * Shows how these components can work together in a real application
 */

import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, Text, TouchableOpacity } from 'react-native';
import { IdentificationResults, AlternativeMatches, IdentificationFeedback } from '../components';
import { PlantIdError } from '../../../core/types/plantIdentification';
import { PlantInfo } from '../../../core/types/plantIdentification';

// Sample plant data for demonstration
const samplePlants: PlantInfo[] = [
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
      temperature: '65-85°F',
      humidity: 'High',
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
      temperature: '65-85°F',
      humidity: 'Average',
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
      temperature: '65-80°F',
      humidity: 'Average to high',
    },
  },
  {
    scientificName: 'Scindapsus pictus',
    commonNames: ['Satin Pothos', 'Silver Philodendron'],
    family: 'Araceae',
    genus: 'Scindapsus',
    confidence: 0.45,
    imageUrl: 'https://example.com/scindapsus.jpg',
    description: 'A trailing plant with silver-spotted leaves.',
    careInfo: {
      watering: 'Low to medium',
      lightRequirements: 'Medium indirect',
      temperature: '65-85°F',
      humidity: 'Average to high',
    },
  },
];

/**
 * Demo screen that integrates IdentificationResults with AlternativeMatches
 * Shows how these components can work together in a real application
 * 
 * @returns {JSX.Element} Rendered component
 */
function IdentificationWithAlternativesScreen(): JSX.Element {
  // State for selected plant index
  const [selectedPlantIndex, setSelectedPlantIndex] = useState<number>(0);
  
  // State for identification status
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('success');
  
  // Sample error for demonstration
  const [error, setError] = useState<PlantIdError | null>(null);

  // Handle plant selection
  const handleSelectPlant = (plant: PlantInfo, index: number) => {
    setSelectedPlantIndex(index);
    console.log(`Selected plant: ${plant.scientificName}`);
  };

  // Handle retry action
  const handleRetry = () => {
    setStatus('loading');
    setError(null);
    // Simulate API call
    setTimeout(() => {
      setStatus('success');
    }, 1500);
  };
  
  // Handle retake photo action
  const handleRetakePhoto = () => {
    console.log('Retake photo action');
    setError(null);
  };
  
  // Simulate error for demonstration
  const simulateError = () => {
    setStatus('error');
    setError({
      code: 'NO_PLANT_DETECTED',
      message: 'No plant was detected in the image',
      details: 'The image does not contain a recognizable plant',
      timestamp: new Date().toISOString(),
      recoverable: true,
    });
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Plant Identification</Text>
        <Text style={styles.subtitle}>
          Integrated identification results with alternative matches
        </Text>
      </View>

      {/* Main identification result */}
      <View style={styles.mainResultContainer}>
        {status === 'error' ? (
          <IdentificationFeedback
            error={error}
            imageUri="https://example.com/sample-plant-image.jpg"
            onRetakePhoto={handleRetakePhoto}
            onRetryIdentification={handleRetry}
          />
        ) : (
          <IdentificationResults
            isLoading={status === 'loading'}
            plants={status === 'success' ? [samplePlants[selectedPlantIndex]] : []}
            confidence={samplePlants[selectedPlantIndex]?.confidence || 0}
            error={error}
            onRetry={handleRetry}
            onSelectPlant={() => console.log('Select plant action')}
          />
        )}
      </View>

      {/* Alternative matches section - only show when identification is successful */}
      {status === 'success' && samplePlants.length > 1 && (
        <View style={styles.alternativesContainer}>
          <AlternativeMatches
            plants={samplePlants}
            selectedPlantIndex={selectedPlantIndex}
            onSelectPlant={handleSelectPlant}
            showDetails={false}
          />
        </View>
      )}

      {/* Integration explanation */}
      <View style={styles.explanationContainer}>
        <Text style={styles.explanationTitle}>About This Integration</Text>
        <Text style={styles.explanationText}>
          This screen demonstrates how the IdentificationResults, AlternativeMatches, 
          and IdentificationFeedback components can be integrated to create a complete 
          plant identification experience.
        </Text>
        <Text style={styles.explanationText}>
          The IdentificationResults component displays detailed information about the 
          currently selected plant, while the AlternativeMatches component allows users 
          to browse and select from other potential matches if the primary identification 
          is incorrect.
        </Text>
        <Text style={styles.explanationText}>
          The IdentificationFeedback component provides helpful suggestions when 
          identification fails, guiding users on how to take better photos for more 
          accurate results.
        </Text>
        <Text style={styles.explanationText}>
          In a real application, these components would be connected to the plant 
          identification API and would update based on actual identification results.
        </Text>
      </View>
      
      {/* Demo Controls */}
      <View style={styles.demoControls}>
        <Text style={styles.demoTitle}>Demo Controls</Text>
        <View style={styles.buttonContainer}>
          <TouchableOpacity style={styles.demoButton} onPress={simulateError}>
            <Text style={styles.buttonText}>Simulate Error</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.demoButton} onPress={handleRetry}>
            <Text style={styles.buttonText}>Reset Demo</Text>
          </TouchableOpacity>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f8f0',
  },
  header: {
    padding: 16,
    backgroundColor: '#2d5a2d',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#e0f0e0',
  },
  mainResultContainer: {
    marginTop: 16,
    marginHorizontal: 16,
  },
  alternativesContainer: {
    marginHorizontal: 16,
  },
  explanationContainer: {
    padding: 16,
    backgroundColor: 'white',
    margin: 16,
    borderRadius: 8,
    marginBottom: 16,
  },
  explanationTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2d5a2d',
    marginBottom: 8,
  },
  explanationText: {
    fontSize: 14,
    color: '#333',
    marginBottom: 8,
    lineHeight: 20,
  },
  demoControls: {
    padding: 16,
    backgroundColor: 'white',
    margin: 16,
    borderRadius: 8,
    marginBottom: 24,
  },
  demoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2d5a2d',
    marginBottom: 12,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  demoButton: {
    backgroundColor: '#2d5a2d',
    padding: 12,
    borderRadius: 6,
    flex: 1,
    marginHorizontal: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: 'white',
    fontWeight: 'bold',
  },
});

export default IdentificationWithAlternativesScreen;