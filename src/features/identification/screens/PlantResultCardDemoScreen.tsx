/**
 * PlantResultCardDemoScreen
 * Demo screen to showcase the PlantResultCard component with different plants and confidence levels
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Switch,
} from 'react-native';
import { PlantResultCard } from '../components';
import { PlantInfo } from '../../../core/types/plantIdentification';

// Sample plant data for demonstration
const samplePlants: PlantInfo[] = [
  {
    id: '1',
    scientificName: 'Monstera deliciosa',
    commonNames: ['Swiss Cheese Plant', 'Split-leaf Philodendron'],
    family: 'Araceae',
    genus: 'Monstera',
    confidence: 0.92,
    imageUrl: 'https://example.com/monstera.jpg',
    description: 'A popular tropical plant known for its distinctive split leaves.',
    careInfo: {
      watering: 'Medium',
      lightRequirements: 'Bright indirect light',
      soilType: 'Well-draining potting mix',
      fertilization: 'Monthly during growing season',
    },
  },
  {
    id: '2',
    scientificName: 'Ficus lyrata',
    commonNames: ['Fiddle Leaf Fig'],
    family: 'Moraceae',
    genus: 'Ficus',
    confidence: 0.65,
    imageUrl: 'https://example.com/ficus.jpg',
    description: 'A popular indoor tree with large, violin-shaped leaves.',
    careInfo: {
      watering: 'Low to medium',
      lightRequirements: 'Bright indirect light',
      soilType: 'Well-draining potting mix',
      fertilization: 'Every 1-2 months during growing season',
    },
  },
  {
    id: '3',
    scientificName: 'Sansevieria trifasciata',
    commonNames: ['Snake Plant', 'Mother-in-law\'s Tongue'],
    family: 'Asparagaceae',
    genus: 'Sansevieria',
    confidence: 0.35,
    imageUrl: 'https://example.com/sansevieria.jpg',
    description: 'A hardy succulent with stiff, upright leaves.',
    careInfo: {
      watering: 'Low',
      lightRequirements: 'Low to bright indirect light',
      soilType: 'Well-draining cactus mix',
      fertilization: 'Rarely, 1-2 times per year',
    },
  },
];

function PlantResultCardDemoScreen(): JSX.Element {
  const [compactMode, setCompactMode] = useState(false);
  const [selectedPlant, setSelectedPlant] = useState<PlantInfo | null>(null);

  // Toggle between compact and full card mode
  const toggleCompactMode = () => setCompactMode(!compactMode);

  // Handle plant card press
  const handlePlantPress = (plant: PlantInfo) => {
    setSelectedPlant(plant);
  };

  // Close selected plant detail
  const closeDetail = () => {
    setSelectedPlant(null);
  };

  return (
    <View style={styles.container}>
      {/* Header with toggle */}
      <View style={styles.header}>
        <Text style={styles.title}>Plant Result Cards</Text>
        <View style={styles.toggleContainer}>
          <Text style={styles.toggleLabel}>Compact Mode</Text>
          <Switch
            value={compactMode}
            onValueChange={toggleCompactMode}
            trackColor={{ false: '#e0e0e0', true: '#4caf50' }}
            thumbColor="#ffffff"
          />
        </View>
      </View>

      {/* Selected plant detail */}
      {selectedPlant && (
        <View style={styles.detailContainer}>
          <View style={styles.detailHeader}>
            <Text style={styles.detailTitle}>Selected Plant</Text>
            <TouchableOpacity onPress={closeDetail} style={styles.closeButton}>
              <Text style={styles.closeButtonText}>Close</Text>
            </TouchableOpacity>
          </View>
          <PlantResultCard plant={selectedPlant} compact={false} />
        </View>
      )}

      {/* Plant cards list */}
      <ScrollView style={styles.cardList}>
        <Text style={styles.sectionTitle}>
          {compactMode ? 'Compact Cards' : 'Full Cards'}
        </Text>
        
        {samplePlants.map((plant) => (
          <PlantResultCard
            key={plant.id}
            plant={plant}
            compact={compactMode}
            onPress={() => handlePlantPress(plant)}
          />
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: '#2d5a2d',
    padding: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#ffffff',
  },
  toggleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  toggleLabel: {
    color: '#ffffff',
    marginRight: 8,
    fontSize: 14,
  },
  cardList: {
    flex: 1,
    padding: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#555',
    marginBottom: 16,
  },
  detailContainer: {
    backgroundColor: '#ffffff',
    margin: 16,
    borderRadius: 8,
    overflow: 'hidden',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 5,
  },
  detailHeader: {
    backgroundColor: '#f0f0f0',
    padding: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  detailTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  closeButton: {
    padding: 4,
  },
  closeButtonText: {
    color: '#2d5a2d',
    fontWeight: '600',
  },
});

export default PlantResultCardDemoScreen;