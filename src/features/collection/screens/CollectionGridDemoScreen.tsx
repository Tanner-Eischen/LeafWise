/**
 * CollectionGridDemoScreen
 * Demo screen to showcase the CollectionGrid component with sample data
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  TouchableOpacity,
  Switch,
  Alert,
} from 'react-native';
import { CollectionGrid } from '../components';
import { PlantCollection, CollectionItem } from '../types';

// Sample collections data for demonstration
const sampleCollections: PlantCollection[] = [
  {
    id: '1',
    userId: 'user1',
    name: 'My Garden Plants',
    description: 'Plants in my home garden',
    isDefault: true,
    itemCount: 12,
    coverImage: 'https://example.com/garden.jpg',
    tags: ['garden', 'outdoor'],
    isPublic: false,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    id: '2',
    userId: 'user1',
    name: 'Indoor Plants',
    description: 'My collection of houseplants',
    isDefault: false,
    itemCount: 8,
    coverImage: 'https://example.com/indoor.jpg',
    tags: ['indoor', 'houseplants'],
    isPublic: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    id: '3',
    userId: 'user1',
    name: 'Succulents',
    description: 'Drought-resistant plants',
    isDefault: false,
    itemCount: 15,
    coverImage: 'https://example.com/succulents.jpg',
    tags: ['succulents', 'desert'],
    isPublic: true,
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    id: '4',
    userId: 'user1',
    name: 'Herbs',
    description: 'Culinary and medicinal herbs',
    isDefault: false,
    itemCount: 6,
    coverImage: 'https://example.com/herbs.jpg',
    tags: ['herbs', 'edible'],
    isPublic: false,
    createdAt: new Date(),
    updatedAt: new Date(),
  },
];

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
    description: 'A popular tropical plant known for its distinctive split leaves.',
    imageUrl: 'https://example.com/monstera.jpg',
    location: { latitude: 37.7749, longitude: -122.4194 },
    collectedAt: new Date(),
    notes: 'Thriving in bright indirect light',
    isFavorite: true,
    tags: ['tropical', 'large-leaf'],
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
    description: 'A popular indoor tree with large, violin-shaped leaves.',
    imageUrl: 'https://example.com/ficus.jpg',
    location: { latitude: 37.7749, longitude: -122.4194 },
    collectedAt: new Date(),
    notes: 'Needs consistent watering',
    isFavorite: false,
    tags: ['indoor', 'tree'],
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
    description: 'A hardy succulent with upright, sword-like leaves.',
    imageUrl: 'https://example.com/sansevieria.jpg',
    location: { latitude: 37.7749, longitude: -122.4194 },
    collectedAt: new Date(),
    notes: 'Very low maintenance',
    isFavorite: true,
    tags: ['succulent', 'air-purifying'],
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    id: '104',
    collectionId: '2',
    userId: 'user1',
    scientificName: 'Epipremnum aureum',
    commonNames: ['Pothos', 'Devil\'s Ivy'],
    family: 'Araceae',
    genus: 'Epipremnum',
    description: 'A trailing vine with heart-shaped leaves.',
    imageUrl: 'https://example.com/pothos.jpg',
    location: { latitude: 37.7749, longitude: -122.4194 },
    collectedAt: new Date(),
    notes: 'Easy to propagate',
    isFavorite: false,
    tags: ['vine', 'hanging'],
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    id: '105',
    collectionId: '3',
    userId: 'user1',
    scientificName: 'Echeveria elegans',
    commonNames: ['Mexican Snowball', 'White Mexican Rose'],
    family: 'Crassulaceae',
    genus: 'Echeveria',
    description: 'A rosette-forming succulent with pale blue-green leaves.',
    imageUrl: 'https://example.com/echeveria.jpg',
    location: { latitude: 37.7749, longitude: -122.4194 },
    collectedAt: new Date(),
    notes: 'Needs well-draining soil',
    isFavorite: true,
    tags: ['rosette', 'drought-resistant'],
    createdAt: new Date(),
    updatedAt: new Date(),
  },
  {
    id: '106',
    collectionId: '4',
    userId: 'user1',
    scientificName: 'Ocimum basilicum',
    commonNames: ['Sweet Basil'],
    family: 'Lamiaceae',
    genus: 'Ocimum',
    description: 'A culinary herb with aromatic leaves.',
    imageUrl: 'https://example.com/basil.jpg',
    location: { latitude: 37.7749, longitude: -122.4194 },
    collectedAt: new Date(),
    notes: 'Harvest regularly to promote growth',
    isFavorite: false,
    tags: ['herb', 'edible', 'annual'],
    createdAt: new Date(),
    updatedAt: new Date(),
  },
];

/**
 * Demo screen for the CollectionGrid component
 * Shows both collection and item display modes
 * 
 * @returns Rendered component
 */
function CollectionGridDemoScreen(): JSX.Element {
  const [displayMode, setDisplayMode] = useState<'collections' | 'items'>('collections');
  const [isLoading, setIsLoading] = useState(false);

  // Toggle between collections and items display
  const toggleDisplayMode = () => {
    setDisplayMode(prev => prev === 'collections' ? 'items' : 'collections');
  };

  // Simulate loading
  const simulateLoading = () => {
    setIsLoading(true);
    setTimeout(() => setIsLoading(false), 1500);
  };

  // Handle collection selection
  const handleSelectCollection = (collection: PlantCollection) => {
    Alert.alert(
      'Collection Selected',
      `You selected: ${collection.name}`,
      [{ text: 'OK', onPress: () => console.log('OK Pressed') }]
    );
  };

  // Handle item selection
  const handleSelectItem = (item: CollectionItem) => {
    Alert.alert(
      'Plant Selected',
      `You selected: ${item.scientificName}`,
      [{ text: 'OK', onPress: () => console.log('OK Pressed') }]
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>Plant Collections</Text>
        <View style={styles.controls}>
          <View style={styles.toggleContainer}>
            <Text style={styles.toggleLabel}>
              {displayMode === 'collections' ? 'Collections' : 'Plants'}
            </Text>
            <Switch
              value={displayMode === 'items'}
              onValueChange={toggleDisplayMode}
              trackColor={{ false: '#e0e0e0', true: '#4a7c4a' }}
              thumbColor="#ffffff"
            />
          </View>
          <TouchableOpacity style={styles.loadingButton} onPress={simulateLoading}>
            <Text style={styles.loadingButtonText}>Simulate Loading</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Collection Grid */}
      <CollectionGrid
        collections={sampleCollections}
        items={sampleItems}
        mode={displayMode}
        isLoading={isLoading}
        onSelectCollection={handleSelectCollection}
        onSelectItem={handleSelectItem}
        showSearch={true}
        itemsPerPage={4}
        emptyStateMessage={`No ${displayMode === 'collections' ? 'collections' : 'plants'} found`}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8faf8',
  },
  header: {
    backgroundColor: '#2d5a2d',
    padding: 16,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 8,
  },
  controls: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
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
  loadingButton: {
    backgroundColor: '#ffffff',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 4,
  },
  loadingButtonText: {
    color: '#2d5a2d',
    fontWeight: 'bold',
    fontSize: 12,
  },
});

export default CollectionGridDemoScreen;