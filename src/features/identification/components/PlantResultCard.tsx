/**
 * PlantResultCard Component
 * A card component that displays plant identification results with confidence visualization
 * Demonstrates real-world usage of the ConfidenceScoreVisualizer component
 */

import React from 'react';
import { View, Text, Image, StyleSheet, TouchableOpacity } from 'react-native';
import { PlantInfo } from '../../../core/types/plantIdentification';
import ConfidenceScoreVisualizer from './ConfidenceScoreVisualizer';

interface PlantResultCardProps {
  plant: PlantInfo;
  onPress?: () => void;
  compact?: boolean;
}

/**
 * Component for displaying plant identification results in a card format
 * Includes plant image, name, and confidence visualization
 * 
 * @param props - Component props
 * @returns Rendered component
 */
function PlantResultCard({ 
  plant, 
  onPress, 
  compact = false 
}: PlantResultCardProps): JSX.Element {
  return (
    <TouchableOpacity 
      style={[styles.card, compact && styles.compactCard]} 
      onPress={onPress}
      activeOpacity={0.8}
    >
      {/* Plant image */}
      <View style={[styles.imageContainer, compact && styles.compactImageContainer]}>
        {plant.imageUrl ? (
          <Image 
            source={{ uri: plant.imageUrl }} 
            style={styles.image} 
            resizeMode="cover" 
          />
        ) : (
          <View style={styles.noImageContainer}>
            <Text style={styles.noImageText}>No Image</Text>
          </View>
        )}
      </View>
      
      <View style={styles.contentContainer}>
        <View style={styles.infoContainer}>
          {/* Plant name */}
          <View>
            <Text style={styles.scientificName}>{plant.scientificName}</Text>
            {plant.commonNames && plant.commonNames.length > 0 && (
              <Text style={styles.commonName}>
                {plant.commonNames[0]}
              </Text>
            )}
          </View>
          
          {/* Confidence visualizer */}
          <View style={styles.confidenceContainer}>
            <ConfidenceScoreVisualizer 
              confidence={plant.confidence} 
              size={compact ? 40 : 50} 
              strokeWidth={compact ? 4 : 5}
              showLabel={!compact}
            />
          </View>
        </View>
        
        {/* Additional info (only in full mode) */}
        {!compact && (
          <View style={styles.detailsContainer}>
            {/* Taxonomy info */}
            {(plant.family || plant.genus) && (
              <View style={styles.taxonomyRow}>
                {plant.family && (
                  <Text style={styles.taxonomyText}>Family: {plant.family}</Text>
                )}
                {plant.genus && (
                  <Text style={styles.taxonomyText}>Genus: {plant.genus}</Text>
                )}
              </View>
            )}
          </View>
        )}
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    overflow: 'hidden',
    marginBottom: 16,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  compactCard: {
    flexDirection: 'row',
    height: 80,
  },
  imageContainer: {
    height: 180,
    width: '100%',
    backgroundColor: '#f0f0f0',
  },
  compactImageContainer: {
    height: 80,
    width: 80,
  },
  image: {
    width: '100%',
    height: '100%',
  },
  noImageContainer: {
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#e0e0e0',
  },
  noImageText: {
    color: '#757575',
    fontSize: 14,
  },
  contentContainer: {
    padding: 12,
    flex: 1,
  },
  infoContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  scientificName: {
    fontSize: 16,
    fontWeight: 'bold',
    fontStyle: 'italic',
    color: '#2d5a2d',
  },
  commonName: {
    fontSize: 14,
    color: '#4a7c4a',
    marginTop: 2,
  },
  confidenceContainer: {
    alignItems: 'center',
  },
  detailsContainer: {
    marginTop: 12,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
  },
  taxonomyRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  taxonomyText: {
    fontSize: 14,
    color: '#555',
    marginRight: 8,
  },
});

export default PlantResultCard;