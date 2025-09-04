/**
 * IdentificationResults Component
 * Displays plant identification results including plant name, confidence score, and basic information
 * Handles loading states and error display for the plant identification feature
 */

import React from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { PlantInfo, PlantIdError } from '../../../core/types/plantIdentification';
import ConfidenceScoreVisualizer from './ConfidenceScoreVisualizer';

interface IdentificationResultsProps {
  isLoading: boolean;
  plants: PlantInfo[];
  confidence: number;
  error: PlantIdError | null;
  onRetry?: () => void;
  onSelectPlant?: (plant: PlantInfo) => void;
}

/**
 * Component for displaying plant identification results
 * Shows loading indicator, error message, or plant information based on current state
 * 
 * @param {IdentificationResultsProps} props - Component props
 * @returns {JSX.Element} Rendered component
 */
function IdentificationResults({
  isLoading,
  plants,
  confidence,
  error,
  onRetry,
  onSelectPlant,
}: IdentificationResultsProps): JSX.Element {
  // Format confidence as percentage
  const formatConfidence = (value: number): string => {
    return `${Math.round(value * 100)}%`;
  };

  // Render loading state
  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#2d5a2d" />
        <Text style={styles.loadingText}>Identifying plant...</Text>
      </View>
    );
  }

  // Render error state
  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorTitle}>Identification Failed</Text>
        <Text style={styles.errorMessage}>{error.message}</Text>
        {onRetry && (
          <TouchableOpacity style={styles.retryButton} onPress={onRetry}>
            <Text style={styles.retryButtonText}>Try Again</Text>
          </TouchableOpacity>
        )}
      </View>
    );
  }

  // Render empty state
  if (!plants || plants.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No plants identified</Text>
        {onRetry && (
          <TouchableOpacity style={styles.retryButton} onPress={onRetry}>
            <Text style={styles.retryButtonText}>Try Again</Text>
          </TouchableOpacity>
        )}
      </View>
    );
  }

  // Render results
  return (
    <ScrollView style={styles.container}>
      <Text style={styles.resultsTitle}>Identification Results</Text>
      
      {plants.map((plant, index) => (
        <TouchableOpacity
          key={`${plant.scientificName}-${index}`}
          style={styles.plantCard}
          onPress={() => onSelectPlant && onSelectPlant(plant)}
          activeOpacity={onSelectPlant ? 0.7 : 1}
        >
          {/* Plant image */}
          {plant.imageUrl ? (
            <Image 
              source={{ uri: plant.imageUrl }} 
              style={styles.plantImage} 
              resizeMode="cover"
            />
          ) : (
            <View style={styles.noImageContainer}>
              <Text style={styles.noImageText}>No image available</Text>
            </View>
          )}
          
          <View style={styles.plantInfo}>
            {/* Scientific name */}
            <Text style={styles.scientificName}>{plant.scientificName}</Text>
            
            {/* Common names */}
            {plant.commonNames && plant.commonNames.length > 0 && (
              <Text style={styles.commonNames}>
                {plant.commonNames.slice(0, 2).join(', ')}
              </Text>
            )}
            
            {/* Confidence score visualization */}
            <View style={styles.confidenceContainer}>
              <ConfidenceScoreVisualizer 
                confidence={plant.confidence} 
                size={60} 
                strokeWidth={6}
                style={styles.confidenceVisualizer}
              />
            </View>
            
            {/* Taxonomy info */}
            {(plant.family || plant.genus) && (
              <View style={styles.taxonomyContainer}>
                {plant.family && (
                  <Text style={styles.taxonomyText}>Family: {plant.family}</Text>
                )}
                {plant.genus && (
                  <Text style={styles.taxonomyText}>Genus: {plant.genus}</Text>
                )}
              </View>
            )}
            
            {/* Care info preview */}
            {plant.careInfo && (
              <View style={styles.careInfoPreview}>
                {plant.careInfo.watering && (
                  <Text style={styles.careInfoText}>Water: {plant.careInfo.watering}</Text>
                )}
                {plant.careInfo.lightRequirements && (
                  <Text style={styles.careInfoText}>Light: {plant.careInfo.lightRequirements}</Text>
                )}
              </View>
            )}
          </View>
        </TouchableOpacity>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f8f0',
    padding: 16,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: '#2d5a2d',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  errorTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#e53935',
    marginBottom: 8,
  },
  errorMessage: {
    fontSize: 16,
    color: '#555',
    textAlign: 'center',
    marginBottom: 16,
  },
  retryButton: {
    backgroundColor: '#2d5a2d',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 8,
    marginTop: 8,
  },
  retryButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '500',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  emptyText: {
    fontSize: 16,
    color: '#555',
    marginBottom: 16,
  },
  resultsTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#2d5a2d',
    marginBottom: 16,
    textAlign: 'center',
  },
  plantCard: {
    backgroundColor: 'white',
    borderRadius: 12,
    marginBottom: 16,
    overflow: 'hidden',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  plantImage: {
    height: 180,
    width: '100%',
    backgroundColor: '#e0e0e0',
  },
  noImageContainer: {
    height: 120,
    width: '100%',
    backgroundColor: '#e0e0e0',
    justifyContent: 'center',
    alignItems: 'center',
  },
  noImageText: {
    color: '#757575',
    fontSize: 14,
  },
  plantInfo: {
    padding: 16,
  },
  scientificName: {
    fontSize: 18,
    fontWeight: 'bold',
    fontStyle: 'italic',
    color: '#2d5a2d',
    marginBottom: 4,
  },
  commonNames: {
    fontSize: 16,
    color: '#4a7c4a',
    marginBottom: 8,
  },
  confidenceContainer: {
    marginVertical: 12,
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  confidenceVisualizer: {
    marginVertical: 4,
  },
  taxonomyContainer: {
    marginBottom: 8,
  },
  taxonomyText: {
    fontSize: 14,
    color: '#555',
  },
  careInfoPreview: {
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
  },
  careInfoText: {
    fontSize: 14,
    color: '#555',
    marginBottom: 2,
  },
});

export default IdentificationResults;