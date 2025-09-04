/**
 * PlantDetailView Component
 * Displays detailed information about a plant collection item
 * Shows plant images, scientific/common names, description, care info, and metadata
 */

import React from 'react';
import {
  View,
  Text,
  Image,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { CollectionItem, PlantCareInfo } from '../types';
import { formatDate, formatRelativeTime } from '../utils/collectionOrganizer';

interface PlantDetailViewProps {
  item: CollectionItem;
  onClose?: () => void;
  onEdit?: (item: CollectionItem) => void;
  onAddToCollection?: (item: CollectionItem) => void;
  onToggleFavorite?: (item: CollectionItem) => void;
}

/**
 * Component for displaying detailed information about a plant
 * 
 * @param props - Component props
 * @returns Rendered component
 */
export function PlantDetailView({
  item,
  onClose,
  onEdit,
  onAddToCollection,
  onToggleFavorite,
}: PlantDetailViewProps): JSX.Element {
  // Render care info section if available
  const renderCareInfo = (careInfo: PlantCareInfo) => {
    const careItems = [
      { label: 'Watering', value: careInfo.watering },
      { label: 'Light', value: careInfo.lightRequirements },
      { label: 'Soil', value: careInfo.soilPreferences },
      { label: 'Temperature', value: careInfo.temperatureRange },
      { label: 'Humidity', value: careInfo.humidityPreferences },
      { label: 'Fertilization', value: careInfo.fertilization },
      { label: 'Growth Rate', value: careInfo.growthRate },
    ];

    return (
      <View style={styles.careInfoContainer}>
        {careItems.map((care, index) => (
          care.value ? (
            <View key={index} style={styles.careItem}>
              <Text style={styles.careLabel}>{care.label}:</Text>
              <Text style={styles.careValue}>{care.value}</Text>
            </View>
          ) : null
        ))}
        
        {careInfo.propagationMethods && careInfo.propagationMethods.length > 0 && (
          <View style={styles.careItem}>
            <Text style={styles.careLabel}>Propagation:</Text>
            <Text style={styles.careValue}>{careInfo.propagationMethods.join(', ')}</Text>
          </View>
        )}
        
        {careInfo.edibleParts && careInfo.edibleParts.length > 0 && (
          <View style={styles.careItem}>
            <Text style={styles.careLabel}>Edible Parts:</Text>
            <Text style={styles.careValue}>{careInfo.edibleParts.join(', ')}</Text>
          </View>
        )}
        
        {careInfo.toxicity && (
          <View style={styles.careItem}>
            <Text style={styles.careLabel}>Toxicity:</Text>
            <Text style={styles.careValue}>{careInfo.toxicity}</Text>
          </View>
        )}
        
        {careInfo.pestsAndDiseases && careInfo.pestsAndDiseases.length > 0 && (
          <View style={styles.careItem}>
            <Text style={styles.careLabel}>Common Pests & Diseases:</Text>
            <Text style={styles.careValue}>{careInfo.pestsAndDiseases.join(', ')}</Text>
          </View>
        )}
      </View>
    );
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {/* Header with close button */}
      <View style={styles.header}>
        <TouchableOpacity onPress={onClose} style={styles.closeButton}>
          <Text style={styles.closeButtonText}>×</Text>
        </TouchableOpacity>
      </View>
      
      {/* Plant image */}
      <View style={styles.imageContainer}>
        {item.imageUrl ? (
          <Image 
            source={{ uri: item.imageUrl }} 
            style={styles.image} 
            resizeMode="cover" 
          />
        ) : (
          <View style={styles.noImageContainer}>
            <Text style={styles.noImageText}>No Image Available</Text>
          </View>
        )}
        {item.isFavorite && (
          <View style={styles.favoriteBadge}>
            <Text style={styles.favoriteBadgeText}>★</Text>
          </View>
        )}
      </View>
      
      {/* Plant name and taxonomy */}
      <View style={styles.nameContainer}>
        <Text style={styles.scientificName}>{item.scientificName}</Text>
        {item.commonNames && item.commonNames.length > 0 && (
          <Text style={styles.commonName}>{item.commonNames.join(', ')}</Text>
        )}
        <View style={styles.taxonomyContainer}>
          {item.family && (
            <Text style={styles.taxonomyText}>Family: {item.family}</Text>
          )}
          {item.genus && (
            <Text style={styles.taxonomyText}>Genus: {item.genus}</Text>
          )}
        </View>
      </View>
      
      {/* Action buttons */}
      <View style={styles.actionButtonsContainer}>
        {onEdit && (
          <TouchableOpacity 
            style={[styles.actionButton, styles.editButton]} 
            onPress={() => onEdit(item)}
          >
            <Text style={styles.actionButtonText}>Edit</Text>
          </TouchableOpacity>
        )}
        {onAddToCollection && (
          <TouchableOpacity 
            style={[styles.actionButton, styles.addButton]} 
            onPress={() => onAddToCollection(item)}
          >
            <Text style={styles.actionButtonText}>Add to Collection</Text>
          </TouchableOpacity>
        )}
        {onToggleFavorite && (
          <TouchableOpacity 
            style={[styles.actionButton, styles.favoriteButton]} 
            onPress={() => onToggleFavorite(item)}
          >
            <Text style={styles.actionButtonText}>
              {item.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'}
            </Text>
          </TouchableOpacity>
        )}
      </View>
      
      {/* Description */}
      {item.description && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Description</Text>
          <Text style={styles.descriptionText}>{item.description}</Text>
        </View>
      )}
      
      {/* Care information */}
      {item.careInfo && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Care Information</Text>
          {renderCareInfo(item.careInfo)}
        </View>
      )}
      
      {/* Notes */}
      {item.notes && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Notes</Text>
          <Text style={styles.notesText}>{item.notes}</Text>
        </View>
      )}
      
      {/* Tags */}
      {item.tags && item.tags.length > 0 && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Tags</Text>
          <View style={styles.tagsContainer}>
            {item.tags.map((tag, index) => (
              <View key={index} style={styles.tag}>
                <Text style={styles.tagText}>{tag}</Text>
              </View>
            ))}
          </View>
        </View>
      )}
      
      {/* Metadata */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Details</Text>
        <View style={styles.metadataContainer}>
          {item.location && (
            <View style={styles.metadataItem}>
              <Text style={styles.metadataLabel}>Location:</Text>
              <Text style={styles.metadataValue}>
                {`${item.location.latitude.toFixed(4)}, ${item.location.longitude.toFixed(4)}`}
              </Text>
            </View>
          )}
          <View style={styles.metadataItem}>
            <Text style={styles.metadataLabel}>Added to Collection:</Text>
            <Text style={styles.metadataValue}>
              {formatDate(item.collectedAt.toString())}
            </Text>
          </View>
          <View style={styles.metadataItem}>
            <Text style={styles.metadataLabel}>Last Updated:</Text>
            <Text style={styles.metadataValue}>
              {formatRelativeTime(item.updatedAt)}
            </Text>
          </View>
        </View>
      </View>
      
      {/* Identification details if available */}
      {item.identificationDetails && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Identification Details</Text>
          <View style={styles.identificationContainer}>
            <View style={styles.metadataItem}>
              <Text style={styles.metadataLabel}>Confidence:</Text>
              <Text style={styles.metadataValue}>
                {`${(item.identificationDetails.confidence * 100).toFixed(0)}%`}
              </Text>
            </View>
            <View style={styles.metadataItem}>
              <Text style={styles.metadataLabel}>Identified:</Text>
              <Text style={styles.metadataValue}>
                {formatDate(item.identificationDetails.identifiedAt.toString())}
              </Text>
            </View>
            <View style={styles.metadataItem}>
              <Text style={styles.metadataLabel}>Source:</Text>
              <Text style={styles.metadataValue}>
                {item.identificationDetails.source.charAt(0).toUpperCase() + 
                 item.identificationDetails.source.slice(1)}
              </Text>
            </View>
            {item.identificationDetails.userFeedback && (
              <View style={styles.metadataItem}>
                <Text style={styles.metadataLabel}>User Feedback:</Text>
                <Text style={styles.metadataValue}>
                  {item.identificationDetails.userFeedback.charAt(0).toUpperCase() + 
                   item.identificationDetails.userFeedback.slice(1)}
                </Text>
              </View>
            )}
          </View>
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  contentContainer: {
    paddingBottom: 40,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    padding: 16,
  },
  closeButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(0, 0, 0, 0.1)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  closeButtonText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000000',
  },
  imageContainer: {
    width: '100%',
    height: 300,
    position: 'relative',
  },
  image: {
    width: '100%',
    height: '100%',
  },
  noImageContainer: {
    width: '100%',
    height: '100%',
    backgroundColor: '#f0f0f0',
    alignItems: 'center',
    justifyContent: 'center',
  },
  noImageText: {
    fontSize: 16,
    color: '#666666',
  },
  favoriteBadge: {
    position: 'absolute',
    top: 16,
    right: 16,
    backgroundColor: 'rgba(255, 215, 0, 0.9)',
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
  },
  favoriteBadgeText: {
    fontSize: 20,
    color: '#ffffff',
  },
  nameContainer: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  scientificName: {
    fontSize: 24,
    fontWeight: 'bold',
    fontStyle: 'italic',
    color: '#000000',
    marginBottom: 4,
  },
  commonName: {
    fontSize: 18,
    color: '#333333',
    marginBottom: 8,
  },
  taxonomyContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 4,
  },
  taxonomyText: {
    fontSize: 14,
    color: '#666666',
    marginRight: 16,
  },
  actionButtonsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  actionButton: {
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  editButton: {
    backgroundColor: '#4a7c4a',
  },
  addButton: {
    backgroundColor: '#3d6b3d',
  },
  favoriteButton: {
    backgroundColor: '#2d5a2d',
  },
  actionButtonText: {
    color: '#ffffff',
    fontWeight: '500',
    fontSize: 14,
  },
  section: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 12,
  },
  descriptionText: {
    fontSize: 16,
    lineHeight: 24,
    color: '#333333',
  },
  careInfoContainer: {
    marginTop: 8,
  },
  careItem: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  careLabel: {
    fontSize: 15,
    fontWeight: '500',
    color: '#333333',
    width: 120,
  },
  careValue: {
    fontSize: 15,
    color: '#666666',
    flex: 1,
  },
  notesText: {
    fontSize: 16,
    fontStyle: 'italic',
    color: '#666666',
    lineHeight: 24,
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  tag: {
    backgroundColor: '#f0f9f0',
    borderRadius: 16,
    paddingVertical: 6,
    paddingHorizontal: 12,
    marginRight: 8,
    marginBottom: 8,
  },
  tagText: {
    fontSize: 14,
    color: '#4a7c4a',
  },
  metadataContainer: {
    marginTop: 8,
  },
  metadataItem: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  metadataLabel: {
    fontSize: 15,
    fontWeight: '500',
    color: '#333333',
    width: 140,
  },
  metadataValue: {
    fontSize: 15,
    color: '#666666',
    flex: 1,
  },
  identificationContainer: {
    marginTop: 8,
  },
});

export default PlantDetailView;