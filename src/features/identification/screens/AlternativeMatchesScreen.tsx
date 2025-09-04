/**
 * AlternativeMatchesScreen
 * Demo screen to showcase the AlternativeMatches component
 */

import React, { useState } from 'react';
import { View, Text, StyleSheet, Button, ScrollView, Switch } from 'react-native';
import { AlternativeMatches } from '../components';
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
      light: 'Bright indirect',
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
      light: 'Low to bright indirect',
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
      light: 'Medium to bright indirect',
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
      light: 'Medium indirect',
      temperature: '65-85°F',
      humidity: 'Average to high',
    },
  },
  {
    scientificName: 'Zamioculcas zamiifolia',
    commonNames: ['ZZ Plant', 'Zanzibar Gem'],
    family: 'Araceae',
    genus: 'Zamioculcas',
    confidence: 0.32,
    imageUrl: 'https://example.com/zzplant.jpg',
    description: 'A hardy plant with glossy, dark green leaves.',
    careInfo: {
      watering: 'Low',
      light: 'Low to bright indirect',
      temperature: '65-80°F',
      humidity: 'Low to average',
    },
  },
];

/**
 * Demo screen for the AlternativeMatches component
 * Shows different states and configurations of the component
 * 
 * @returns {JSX.Element} Rendered component
 */
function AlternativeMatchesScreen(): JSX.Element {
  // State for selected plant index
  const [selectedPlantIndex, setSelectedPlantIndex] = useState<number>(0);
  
  // State for showing detailed view
  const [showDetails, setShowDetails] = useState<boolean>(false);
  
  // State for demo mode
  const [demoMode, setDemoMode] = useState<'normal' | 'empty' | 'single'>('normal');

  // Handle plant selection
  const handleSelectPlant = (plant: PlantInfo, index: number) => {
    setSelectedPlantIndex(index);
    console.log(`Selected plant: ${plant.scientificName}`);
  };

  // Get plants based on demo mode
  const getPlantsForDemo = () => {
    switch (demoMode) {
      case 'empty':
        return [];
      case 'single':
        return [samplePlants[0]];
      case 'normal':
      default:
        return samplePlants;
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Alternative Matches Demo</Text>
        <Text style={styles.subtitle}>
          Demonstration of the AlternativeMatches component with sample data
        </Text>
      </View>

      {/* Demo controls */}
      <View style={styles.demoControls}>
        <View style={styles.demoModeContainer}>
          <Text style={styles.controlLabel}>Demo Mode:</Text>
          <View style={styles.buttonGroup}>
            <Button
              title="Normal"
              onPress={() => setDemoMode('normal')}
              color={demoMode === 'normal' ? '#2d5a2d' : '#888'}
            />
            <Button
              title="Empty"
              onPress={() => setDemoMode('empty')}
              color={demoMode === 'empty' ? '#2d5a2d' : '#888'}
            />
            <Button
              title="Single"
              onPress={() => setDemoMode('single')}
              color={demoMode === 'single' ? '#2d5a2d' : '#888'}
            />
          </View>
        </View>

        <View style={styles.detailsToggle}>
          <Text style={styles.controlLabel}>Show Details:</Text>
          <Switch
            value={showDetails}
            onValueChange={setShowDetails}
            trackColor={{ false: '#ccc', true: '#a0d8a0' }}
            thumbColor={showDetails ? '#2d5a2d' : '#f4f3f4'}
          />
        </View>
      </View>

      {/* Selected plant info */}
      <View style={styles.selectedPlantContainer}>
        <Text style={styles.sectionTitle}>Currently Selected Plant</Text>
        {demoMode === 'normal' && (
          <View style={styles.selectedPlantInfo}>
            <Text style={styles.plantName}>
              {samplePlants[selectedPlantIndex].scientificName}
            </Text>
            {samplePlants[selectedPlantIndex].commonNames && (
              <Text style={styles.commonName}>
                {samplePlants[selectedPlantIndex].commonNames[0]}
              </Text>
            )}
            <Text style={styles.confidence}>
              Confidence: {Math.round(samplePlants[selectedPlantIndex].confidence * 100)}%
            </Text>
          </View>
        )}
        {demoMode !== 'normal' && (
          <Text style={styles.noSelection}>No plant selected</Text>
        )}
      </View>

      {/* AlternativeMatches component */}
      <View style={styles.componentContainer}>
        <AlternativeMatches
          plants={getPlantsForDemo()}
          selectedPlantIndex={selectedPlantIndex}
          onSelectPlant={handleSelectPlant}
          showDetails={showDetails}
        />
      </View>

      {/* Component explanation */}
      <View style={styles.explanationContainer}>
        <Text style={styles.explanationTitle}>About This Component</Text>
        <Text style={styles.explanationText}>
          The AlternativeMatches component displays multiple potential plant matches 
          from the identification process. It allows users to select between different 
          identification results if the primary match is incorrect.
        </Text>
        <Text style={styles.explanationText}>
          Features:
          {"\n"}- Displays confidence scores with color coding
          {"\n"}- Shows scientific and common names
          {"\n"}- Supports horizontal scrolling for compact view
          {"\n"}- Optional detailed view with additional plant information
          {"\n"}- Visual indication of the currently selected plant
        </Text>
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
  demoControls: {
    padding: 16,
    backgroundColor: '#e0f0e0',
    borderBottomWidth: 1,
    borderBottomColor: '#ccc',
  },
  demoModeContainer: {
    marginBottom: 12,
  },
  controlLabel: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#2d5a2d',
    marginBottom: 8,
  },
  buttonGroup: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  detailsToggle: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  selectedPlantContainer: {
    padding: 16,
    backgroundColor: 'white',
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2d5a2d',
    marginBottom: 8,
  },
  selectedPlantInfo: {
    padding: 12,
    backgroundColor: '#f0f8f0',
    borderRadius: 8,
  },
  plantName: {
    fontSize: 16,
    fontWeight: 'bold',
    fontStyle: 'italic',
    color: '#2d5a2d',
  },
  commonName: {
    fontSize: 14,
    color: '#4a7c4a',
    marginBottom: 4,
  },
  confidence: {
    fontSize: 14,
    color: '#555',
  },
  noSelection: {
    fontSize: 14,
    color: '#888',
    fontStyle: 'italic',
  },
  componentContainer: {
    marginBottom: 16,
  },
  explanationContainer: {
    padding: 16,
    backgroundColor: 'white',
    marginBottom: 24,
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
});

export default AlternativeMatchesScreen;