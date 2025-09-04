/**
 * AlternativeMatches Component
 * Displays multiple potential plant matches with confidence levels
 * Allows users to select between different identification results
 */

import React from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  FlatList,
} from 'react-native';
import { PlantInfo } from '../../../core/types/plantIdentification';

interface AlternativeMatchesProps {
  plants: PlantInfo[];
  selectedPlantIndex: number;
  onSelectPlant: (plant: PlantInfo, index: number) => void;
  showDetails?: boolean;
}

/**
 * Component for displaying alternative plant matches
 * Shows multiple potential plant matches with confidence levels
 * Allows users to select between different identification results
 * 
 * @param {AlternativeMatchesProps} props - Component props
 * @returns {React.ReactElement} Rendered component
 */
function AlternativeMatches({
  plants,
  selectedPlantIndex,
  onSelectPlant,
  showDetails = false,
}: AlternativeMatchesProps): React.ReactElement {
  // Format confidence as percentage
  const formatConfidence = (value: number): string => {
    return `${Math.round(value * 100)}%`;
  };

  // Render empty state
  if (!plants || plants.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No alternative matches available</Text>
      </View>
    );
  }

  // Render single match state
  if (plants.length === 1) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No alternative matches found</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Alternative Matches</Text>
      <Text style={styles.subtitle}>
        Select a different match if the primary identification is incorrect
      </Text>
      
      <FlatList
        data={plants}
        keyExtractor={(item, index) => `${item.scientificName}-${index}`}
        horizontal={!showDetails}
        showsHorizontalScrollIndicator={true}
        contentContainerStyle={showDetails ? styles.listContentVertical : styles.listContentHorizontal}
        renderItem={({ item, index }) => {
          const isSelected = index === selectedPlantIndex;
          
          return (
            <TouchableOpacity
              style={[
                showDetails ? styles.plantCardVertical : styles.plantCardHorizontal,
                isSelected && styles.selectedCard
              ]}
              onPress={() => onSelectPlant(item, index)}
              activeOpacity={0.7}
            >
              {/* Plant image */}
              {item.imageUrl ? (
                <Image 
                  source={{ uri: item.imageUrl }} 
                  style={showDetails ? styles.plantImageVertical : styles.plantImageHorizontal} 
                  resizeMode="cover"
                />
              ) : (
                <View style={showDetails ? styles.noImageContainerVertical : styles.noImageContainerHorizontal}>
                  <Text style={styles.noImageText}>No image</Text>
                </View>
              )}
              
              <View style={styles.plantInfo}>
                {/* Scientific name */}
                <Text 
                  style={[styles.scientificName, isSelected && styles.selectedText]} 
                  numberOfLines={1}
                >
                  {item.scientificName}
                </Text>
                
                {/* Common names - only if showDetails or selected */}
                {(showDetails || isSelected) && item.commonNames && item.commonNames.length > 0 && (
                  <Text style={styles.commonNames} numberOfLines={1}>
                    {item.commonNames[0]}
                  </Text>
                )}
                
                {/* Confidence score */}
                <View style={styles.confidenceContainer}>
                  <Text 
                    style={[
                      styles.confidenceValue,
                      item.confidence > 0.7 ? styles.highConfidence :
                      item.confidence > 0.4 ? styles.mediumConfidence :
                      styles.lowConfidence,
                      isSelected && styles.selectedText
                    ]}
                  >
                    {formatConfidence(item.confidence)}
                  </Text>
                </View>
                
                {/* Additional details if showDetails is true */}
                {showDetails && (
                  <View style={styles.detailsContainer}>
                    {item.family && (
                      <Text style={styles.detailText}>Family: {item.family}</Text>
                    )}
                    {item.genus && (
                      <Text style={styles.detailText}>Genus: {item.genus}</Text>
                    )}
                  </View>
                )}
              </View>
              
              {/* Selection indicator */}
              {isSelected && (
                <View style={styles.selectionIndicator}>
                  <Text style={styles.selectionText}>✓</Text>
                </View>
              )}
            </TouchableOpacity>
          );
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#f0f8f0',
    padding: 16,
    borderRadius: 12,
    marginBottom: 16,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2d5a2d',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#555',
    marginBottom: 16,
  },
  listContentHorizontal: {
    paddingRight: 16,
  },
  listContentVertical: {
    paddingBottom: 8,
  },
  plantCardHorizontal: {
    backgroundColor: 'white',
    borderRadius: 12,
    marginRight: 12,
    width: 150,
    overflow: 'hidden',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    position: 'relative',
  },
  plantCardVertical: {
    backgroundColor: 'white',
    borderRadius: 12,
    marginBottom: 12,
    overflow: 'hidden',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    flexDirection: 'row',
    position: 'relative',
  },
  selectedCard: {
    borderWidth: 2,
    borderColor: '#2d5a2d',
    backgroundColor: '#f0f8f0',
  },
  plantImageHorizontal: {
    height: 100,
    width: '100%',
    backgroundColor: '#e0e0e0',
  },
  plantImageVertical: {
    height: 80,
    width: 80,
    backgroundColor: '#e0e0e0',
  },
  noImageContainerHorizontal: {
    height: 100,
    width: '100%',
    backgroundColor: '#e0e0e0',
    justifyContent: 'center',
    alignItems: 'center',
  },
  noImageContainerVertical: {
    height: 80,
    width: 80,
    backgroundColor: '#e0e0e0',
    justifyContent: 'center',
    alignItems: 'center',
  },
  noImageText: {
    color: '#757575',
    fontSize: 12,
  },
  plantInfo: {
    padding: 12,
    flex: 1,
  },
  scientificName: {
    fontSize: 14,
    fontWeight: 'bold',
    fontStyle: 'italic',
    color: '#2d5a2d',
    marginBottom: 2,
  },
  commonNames: {
    fontSize: 12,
    color: '#4a7c4a',
    marginBottom: 4,
  },
  confidenceContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  confidenceValue: {
    fontSize: 14,
    fontWeight: 'bold',
  },
  highConfidence: {
    color: '#388e3c',
  },
  mediumConfidence: {
    color: '#f57c00',
  },
  lowConfidence: {
    color: '#d32f2f',
  },
  selectedText: {
    color: '#2d5a2d',
  },
  detailsContainer: {
    marginTop: 4,
  },
  detailText: {
    fontSize: 12,
    color: '#555',
  },
  emptyContainer: {
    padding: 16,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#f0f8f0',
    borderRadius: 12,
    marginBottom: 16,
  },
  emptyText: {
    fontSize: 14,
    color: '#555',
    textAlign: 'center',
  },
  selectionIndicator: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: '#2d5a2d',
    width: 20,
    height: 20,
    borderRadius: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  selectionText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
});

export default AlternativeMatches;