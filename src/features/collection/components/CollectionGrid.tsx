/**
 * CollectionGrid Component
 * Displays a grid of plant collections with search, filter, and pagination functionality
 * Supports both collection and item display modes
 */

import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  FlatList,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Image,
  ActivityIndicator,
  ListRenderItem,
} from 'react-native';
import { PlantCollection, CollectionItem } from '../types';
import {
  searchItems,
  createSearchIndex,
  sortItemsByDate,
  sortCollectionsByItemCount,
  filterItemsByDateRange,
  generateItemMetadataSummary,
} from '../utils/collectionOrganizer';

interface CollectionGridProps {
  // Data props
  collections?: PlantCollection[];
  items?: CollectionItem[];
  isLoading?: boolean;
  
  // Display mode
  mode: 'collections' | 'items';
  
  // Callbacks
  onSelectCollection?: (collection: PlantCollection) => void;
  onSelectItem?: (item: CollectionItem) => void;
  
  // Optional configuration
  emptyStateMessage?: string;
  showSearch?: boolean;
  initialSearchQuery?: string;
  itemsPerPage?: number;
}

/**
 * Grid component for displaying plant collections or collection items
 * Features search, filtering, smooth scrolling, and pagination
 * 
 * @param props - Component props
 * @returns Rendered component
 */
function CollectionGrid({
  collections = [],
  items = [],
  isLoading = false,
  mode = 'collections',
  onSelectCollection,
  onSelectItem,
  emptyStateMessage = 'No items found',
  showSearch = true,
  initialSearchQuery = '',
  itemsPerPage = 12,
}: CollectionGridProps): JSX.Element {
  // State
  const [searchQuery, setSearchQuery] = useState(initialSearchQuery);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchIndex, setSearchIndex] = useState<Record<string, string>>({});
  
  // Filtered data based on search query
  const [filteredData, setFilteredData] = useState<Array<PlantCollection | CollectionItem>>(
    mode === 'collections' ? collections : items
  );

  // Create search index when items change
  useEffect(() => {
    if (mode === 'items' && items.length > 0) {
      setSearchIndex(createSearchIndex(items));
    }
  }, [items, mode]);

  // Filter data when search query changes
  useEffect(() => {
    if (searchQuery.trim() === '') {
      setFilteredData(mode === 'collections' ? collections : items);
      return;
    }

    if (mode === 'collections') {
      // Filter collections by name or description
      const filtered = collections.filter(collection => {
        const searchableText = `${collection.name} ${collection.description || ''}`
          .toLowerCase();
        return searchableText.includes(searchQuery.toLowerCase());
      });
      setFilteredData(filtered);
    } else {
      // Filter items using search index
      const filtered = searchItems(items, searchIndex, searchQuery);
      setFilteredData(filtered);
    }

    // Reset to first page when search changes
    setCurrentPage(1);
  }, [searchQuery, collections, items, mode, searchIndex]);

  // Calculate pagination
  const totalPages = Math.ceil(filteredData.length / itemsPerPage);
  const paginatedData = filteredData.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  ) as (PlantCollection | CollectionItem)[];

  // Handle search input
  const handleSearch = (text: string) => {
    setSearchQuery(text);
  };

  // Render collection item
  const renderCollectionItem: ListRenderItem<PlantCollection> = ({ item }) => (
    <TouchableOpacity
      style={styles.collectionCard}
      onPress={() => onSelectCollection?.(item)}
      activeOpacity={0.7}
    >
      <View style={styles.imageContainer}>
        {item.coverImage ? (
          <Image source={{ uri: item.coverImage }} style={styles.image} />
        ) : (
          <View style={styles.noImageContainer}>
            <Text style={styles.noImageText}>No Image</Text>
          </View>
        )}
        {item.isDefault && (
          <View style={styles.defaultBadge}>
            <Text style={styles.defaultBadgeText}>Default</Text>
          </View>
        )}
      </View>
      <View style={styles.cardContent}>
        <Text style={styles.collectionName} numberOfLines={1}>
          {item.name}
        </Text>
        <Text style={styles.itemCount}>{item.itemCount} plants</Text>
        {item.description ? (
          <Text style={styles.description} numberOfLines={2}>
            {item.description}
          </Text>
        ) : null}
        {item.tags && item.tags.length > 0 && (
          <View style={styles.tagsContainer}>
            {item.tags.slice(0, 2).map((tag, index) => (
              <View key={index} style={styles.tag}>
                <Text style={styles.tagText}>{tag}</Text>
              </View>
            ))}
            {item.tags.length > 2 && (
              <View style={styles.tag}>
                <Text style={styles.tagText}>+{item.tags.length - 2}</Text>
              </View>
            )}
          </View>
        )}
      </View>
    </TouchableOpacity>
  );

  // Render plant item
  const renderPlantItem: ListRenderItem<CollectionItem> = ({ item }) => (
    <TouchableOpacity
      style={styles.plantCard}
      onPress={() => onSelectItem?.(item)}
      activeOpacity={0.7}
    >
      <View style={styles.imageContainer}>
        {item.imageUrl ? (
          <Image source={{ uri: item.imageUrl }} style={styles.image} />
        ) : (
          <View style={styles.noImageContainer}>
            <Text style={styles.noImageText}>No Image</Text>
          </View>
        )}
        {item.isFavorite && (
          <View style={styles.favoriteBadge}>
            <Text style={styles.favoriteBadgeText}>★</Text>
          </View>
        )}
      </View>
      <View style={styles.cardContent}>
        <Text style={styles.scientificName} numberOfLines={1}>
          {item.scientificName}
        </Text>
        {item.commonNames && item.commonNames.length > 0 && (
          <Text style={styles.commonName} numberOfLines={1}>
            {item.commonNames[0]}
          </Text>
        )}
        <Text style={styles.metadataText} numberOfLines={1}>
          {generateItemMetadataSummary(item)}
        </Text>
      </View>
    </TouchableOpacity>
  );

  // Render pagination controls
  const renderPagination = () => {
    if (totalPages <= 1) return null;

    return (
      <View style={styles.paginationContainer}>
        <TouchableOpacity
          style={[styles.pageButton, currentPage === 1 && styles.disabledButton]}
          onPress={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
          disabled={currentPage === 1}
        >
          <Text style={styles.pageButtonText}>Previous</Text>
        </TouchableOpacity>
        
        <Text style={styles.pageInfo}>
          Page {currentPage} of {totalPages}
        </Text>
        
        <TouchableOpacity
          style={[styles.pageButton, currentPage === totalPages && styles.disabledButton]}
          onPress={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
          disabled={currentPage === totalPages}
        >
          <Text style={styles.pageButtonText}>Next</Text>
        </TouchableOpacity>
      </View>
    );
  };

  // Render empty state
  const renderEmptyState = () => {
    if (isLoading) {
      return (
        <View style={styles.emptyStateContainer}>
          <ActivityIndicator size="large" color="#4a7c4a" />
          <Text style={styles.emptyStateText}>Loading...</Text>
        </View>
      );
    }

    return (
      <View style={styles.emptyStateContainer}>
        <Text style={styles.emptyStateText}>{emptyStateMessage}</Text>
        {searchQuery ? (
          <TouchableOpacity onPress={() => setSearchQuery('')}>
            <Text style={styles.clearSearchText}>Clear search</Text>
          </TouchableOpacity>
        ) : null}
      </View>
    );
  };

  return (
    <View style={styles.container}>
      {/* Search bar */}
      {showSearch && (
        <View style={styles.searchContainer}>
          <TextInput
            style={styles.searchInput}
            placeholder="Search..."
            value={searchQuery}
            onChangeText={handleSearch}
            clearButtonMode="while-editing"
          />
        </View>
      )}

      {/* Grid */}
      {mode === 'collections' ? (
        <FlatList<PlantCollection>
          data={paginatedData as PlantCollection[]}
          renderItem={renderCollectionItem}
          keyExtractor={item => item.id}
          numColumns={2}
          contentContainerStyle={styles.gridContainer}
          ListEmptyComponent={renderEmptyState}
          showsVerticalScrollIndicator={false}
          initialNumToRender={itemsPerPage}
          maxToRenderPerBatch={itemsPerPage}
          windowSize={5}
          removeClippedSubviews={true}
        />
      ) : (
        <FlatList<CollectionItem>
          data={paginatedData as CollectionItem[]}
          renderItem={renderPlantItem}
          keyExtractor={item => item.id}
          numColumns={2}
          contentContainerStyle={styles.gridContainer}
          ListEmptyComponent={renderEmptyState}
          showsVerticalScrollIndicator={false}
          initialNumToRender={itemsPerPage}
          maxToRenderPerBatch={itemsPerPage}
          windowSize={5}
          removeClippedSubviews={true}
        />
      )}

      {/* Pagination */}
      {renderPagination()}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8faf8',
  },
  searchContainer: {
    padding: 16,
    backgroundColor: '#ffffff',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e5e5',
  },
  searchInput: {
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
    padding: 10,
    fontSize: 16,
  },
  gridContainer: {
    padding: 8,
    paddingBottom: 16,
  },
  collectionCard: {
    flex: 1,
    margin: 8,
    backgroundColor: '#ffffff',
    borderRadius: 12,
    overflow: 'hidden',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    maxWidth: '47%',
  },
  plantCard: {
    flex: 1,
    margin: 8,
    backgroundColor: '#ffffff',
    borderRadius: 12,
    overflow: 'hidden',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    maxWidth: '47%',
  },
  imageContainer: {
    height: 120,
    width: '100%',
    backgroundColor: '#f0f0f0',
    position: 'relative',
  },
  image: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
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
  cardContent: {
    padding: 12,
  },
  collectionName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2d5a2d',
    marginBottom: 4,
  },
  scientificName: {
    fontSize: 16,
    fontWeight: 'bold',
    fontStyle: 'italic',
    color: '#2d5a2d',
    marginBottom: 2,
  },
  commonName: {
    fontSize: 14,
    color: '#4a7c4a',
    marginBottom: 4,
  },
  itemCount: {
    fontSize: 14,
    color: '#525252',
    marginBottom: 4,
  },
  description: {
    fontSize: 14,
    color: '#737373',
    marginBottom: 8,
  },
  metadataText: {
    fontSize: 12,
    color: '#737373',
  },
  tagsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  tag: {
    backgroundColor: '#f0f8f0',
    borderRadius: 12,
    paddingHorizontal: 8,
    paddingVertical: 2,
    marginRight: 4,
    marginBottom: 4,
  },
  tagText: {
    fontSize: 12,
    color: '#4a7c4a',
  },
  defaultBadge: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: '#4a7c4a',
    borderRadius: 4,
    paddingHorizontal: 6,
    paddingVertical: 2,
  },
  defaultBadgeText: {
    color: '#ffffff',
    fontSize: 10,
    fontWeight: 'bold',
  },
  favoriteBadge: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: '#f59e0b',
    borderRadius: 12,
    width: 24,
    height: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  favoriteBadgeText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  paginationContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: '#e5e5e5',
    backgroundColor: '#ffffff',
  },
  pageButton: {
    backgroundColor: '#4a7c4a',
    borderRadius: 4,
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  pageButtonText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  disabledButton: {
    backgroundColor: '#e5e5e5',
  },
  pageInfo: {
    fontSize: 14,
    color: '#525252',
  },
  emptyStateContainer: {
    padding: 32,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyStateText: {
    fontSize: 16,
    color: '#525252',
    textAlign: 'center',
    marginBottom: 8,
  },
  clearSearchText: {
    fontSize: 14,
    color: '#4a7c4a',
    fontWeight: 'bold',
  },
});

export default CollectionGrid;