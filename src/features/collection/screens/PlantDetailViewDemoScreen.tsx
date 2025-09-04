/**
 * PlantDetailViewDemoScreen
 * Demo screen to showcase the PlantDetailView component with sample data
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
  FlatList,
  Alert,
} from 'react-native';
import { PlantDetailView } from '../components';
import { CollectionItem } from '../types';

// Sample collection items data for demonstration
const sampleItems: CollectionItem[] = [
  {
    id: '101',
    collectionId: '1',
    userId: 'user1',
    scientificName: 'Monstera deliciosa',
    commonNames: ['Swiss Cheese Plant', 'Split-leaf Philodendron'],
    family: 'Araceae',
    genus: 'Monstera',
    description: 'A popular tropical plant known for its distinctive split leaves. The leaves develop holes (fenestration) as the plant matures. Native to the tropical forests of southern Mexico and Panama, it has become a popular houseplant due to its dramatic foliage and relatively easy care requirements.',
    imageUrl: 'https://example.com/monstera.jpg',
    location: { latitude: 37.7749, longitude: -122.4194 },
    collectedAt: new Date(),
    notes: 'Thriving in bright indirect light. Recently repotted and showing new growth.',
    isFavorite: true,
    tags: ['tropical', 'large-leaf', 'indoor'],
    careInfo: {
      watering: 'Allow soil to dry between waterings',
      lightRequirements: 'Bright indirect light',
      growthRate: 'Fast during growing season',
      soilPreferences: 'Well-draining potting mix',
      temperatureRange: '65-85°F (18-29°C)',
      humidityPreferences: 'High humidity',
      fertilization: 'Monthly during growing season',
      propagationMethods: ['Stem cuttings', 'Air layering'],
      edibleParts: ['Ripe fruit'],
      toxicity: 'Mildly toxic to pets if ingested',
      pestsAndDiseases: ['Spider mites', 'Scale insects', 'Root rot']
    },
    identificationDetails: {
      identificationId: 'id123',
      confidence: 0.92,
      isConfirmed: true,
      userFeedback: 'correct',
      identifiedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 7 days ago
      source: 'api',
      alternativeSuggestions: []
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    id: '102',
    collectionId: '1',
    userId: 'user1',
    scientificName: 'Ficus lyrata',
    commonNames: ['Fiddle Leaf Fig'],
    family: 'Moraceae',
    genus: 'Ficus',
    description: 'A popular indoor tree with large, violin-shaped leaves. Native to western Africa, it grows in lowland tropical rainforests. The plant has become very popular in interior design due to its dramatic, architectural form.',
    imageUrl: 'https://example.com/ficus.jpg',
    location: { latitude: 37.7749, longitude: -122.4194 },
    collectedAt: new Date(),
    notes: 'Needs consistent watering. Sensitive to changes in environment.',
    isFavorite: false,
    tags: ['indoor', 'tree'],
    careInfo: {
      watering: 'Keep soil consistently moist but not soggy',
      lightRequirements: 'Bright indirect light',
      growthRate: 'Moderate',
      soilPreferences: 'Well-draining potting mix',
      temperatureRange: '60-75°F (15-24°C)',
      humidityPreferences: 'Medium to high humidity',
      fertilization: 'Monthly during growing season',
      propagationMethods: ['Air layering', 'Stem cuttings'],
      toxicity: 'Mildly toxic to pets if ingested',
      pestsAndDiseases: ['Spider mites', 'Scale insects', 'Leaf drop']
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    id: '103',
    collectionId: '2',
    userId: 'user1',
    scientificName: 'Sansevieria trifasciata',
    commonNames: ['Snake Plant', 'Mother-in-law\'s Tongue'],
    family: 'Asparagaceae',
    genus: 'Sansevieria',
    description: 'A hardy succulent with upright, sword-like leaves. Native to tropical West Africa, it is known for its ability to purify air and tolerate neglect. The plant has stiff, upright leaves that range from 1-8 feet tall depending on the variety.',
    imageUrl: 'https://example.com/sansevieria.jpg',
    location: { latitude: 37.7749, longitude: -122.4194 },
    collectedAt: new Date(),
    notes: 'Very low maintenance. Can go weeks without water.',
    isFavorite: true,
    tags: ['succulent', 'air-purifying'],
    careInfo: {
      watering: 'Allow soil to dry completely between waterings',
      lightRequirements: 'Low to bright indirect light',
      growthRate: 'Slow',
      soilPreferences: 'Well-draining cactus or succulent mix',
      temperatureRange: '70-90°F (21-32°C)',
      humidityPreferences: 'Low to average humidity',
      fertilization: 'Sparingly, 2-3 times per year',
      propagationMethods: ['Division', 'Leaf cuttings'],
      toxicity: 'Mildly toxic to pets if ingested',
      pestsAndDiseases: ['Mealybugs', 'Root rot']
    },
    identificationDetails: {
      identificationId: 'id125',
      confidence: 0.88,
      isConfirmed: true,
      userFeedback: null,
      identifiedAt: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000), // 14 days ago
      source: 'api',
      alternativeSuggestions: []
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  },
];

/**
 * Demo screen for the PlantDetailView component
 * 
 * @returns Rendered component
 */
export function PlantDetailViewDemoScreen(): JSX.Element {
  const [selectedItem, setSelectedItem] = useState<CollectionItem | null>(null);

  // Handle item selection
  const handleSelectItem = (item: CollectionItem) => {
    setSelectedItem(item);
  };

  // Handle close detail view
  const handleCloseDetail = () => {
    setSelectedItem(null);
  };

  // Handle edit action
  const handleEdit = (item: CollectionItem) => {
    Alert.alert('Edit Plant', `You would edit ${item.scientificName} here`);
  };

  // Handle add to collection action
  const handleAddToCollection = (item: CollectionItem) => {
    Alert.alert('Add to Collection', `You would add ${item.scientificName} to another collection here`);
  };

  // Handle toggle favorite action
  const handleToggleFavorite = (item: CollectionItem) => {
    Alert.alert(
      item.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
      `You would ${item.isFavorite ? 'remove' : 'add'} ${item.scientificName} ${item.isFavorite ? 'from' : 'to'} favorites here`
    );
  };

  // Render item in the list
  const renderItem = ({ item }: { item: CollectionItem }) => (
    <TouchableOpacity 
      style={styles.itemButton} 
      onPress={() => handleSelectItem(item)}
    >
      <Text style={styles.itemButtonText}>{item.scientificName}</Text>
      <Text style={styles.itemButtonSubtext}>{item.commonNames[0]}</Text>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      {selectedItem ? (
        // Show plant detail view when an item is selected
        <PlantDetailView
          item={selectedItem}
          onClose={handleCloseDetail}
          onEdit={handleEdit}
          onAddToCollection={handleAddToCollection}
          onToggleFavorite={handleToggleFavorite}
        />
      ) : (
        // Show list of plants when no item is selected
        <View style={styles.listContainer}>
          <Text style={styles.title}>Plant Detail View Demo</Text>
          <Text style={styles.subtitle}>Select a plant to view details</Text>
          
          <FlatList
            data={sampleItems}
            renderItem={renderItem}
            keyExtractor={(item) => item.id}
            contentContainerStyle={styles.listContent}
          />
          
          <View style={styles.explanationContainer}>
            <Text style={styles.explanationTitle}>About This Component</Text>
            <Text style={styles.explanationText}>
              The PlantDetailView component displays comprehensive information about a plant,
              including its scientific and common names, description, care information, and metadata.
            </Text>
            <Text style={styles.explanationText}>
              Features:
              {"\n"}- Displays plant images with favorite indicator
              {"\n"}- Shows scientific and common names with taxonomy information
              {"\n"}- Provides detailed plant description
              {"\n"}- Displays comprehensive care information
              {"\n"}- Shows user notes and custom tags
              {"\n"}- Includes metadata like location and collection date
              {"\n"}- Shows identification details if available
            </Text>
          </View>
        </View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  listContainer: {
    flex: 1,
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#000000',
  },
  subtitle: {
    fontSize: 16,
    color: '#666666',
    marginBottom: 24,
  },
  listContent: {
    paddingBottom: 16,
  },
  itemButton: {
    backgroundColor: '#f0f9f0',
    padding: 16,
    borderRadius: 8,
    marginBottom: 12,
    borderLeftWidth: 4,
    borderLeftColor: '#4a7c4a',
  },
  itemButtonText: {
    fontSize: 18,
    fontWeight: '500',
    fontStyle: 'italic',
    color: '#000000',
  },
  itemButtonSubtext: {
    fontSize: 14,
    color: '#666666',
    marginTop: 4,
  },
  explanationContainer: {
    marginTop: 24,
    padding: 16,
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
  },
  explanationTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
    color: '#000000',
  },
  explanationText: {
    fontSize: 14,
    lineHeight: 20,
    color: '#333333',
    marginBottom: 8,
  },
});

export default PlantDetailViewDemoScreen;