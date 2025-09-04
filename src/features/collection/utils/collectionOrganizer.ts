/**
 * Collection Organizer Utilities
 * Provides functions for organizing plant collections with metadata
 * Handles timestamp and location formatting for collection items
 */

import { CollectionItem, PlantCollection } from '../types';
import { Location } from '../../../core/types';

/**
 * Format a date for display
 * 
 * @param date - Date to format
 * @returns Formatted date string
 */
export function formatDate(date: Date | string): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  
  return dateObj.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
}

/**
 * Format a timestamp to show relative time
 * 
 * @param date - Date to format
 * @returns Relative time string (e.g., "2 days ago")
 */
export function formatRelativeTime(date: Date | string): string {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();
  
  const diffMs = now.getTime() - dateObj.getTime();
  const diffSecs = Math.floor(diffMs / 1000);
  const diffMins = Math.floor(diffSecs / 60);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);
  const diffMonths = Math.floor(diffDays / 30);
  const diffYears = Math.floor(diffDays / 365);
  
  if (diffSecs < 60) {
    return 'just now';
  } else if (diffMins < 60) {
    return `${diffMins} ${diffMins === 1 ? 'minute' : 'minutes'} ago`;
  } else if (diffHours < 24) {
    return `${diffHours} ${diffHours === 1 ? 'hour' : 'hours'} ago`;
  } else if (diffDays < 30) {
    return `${diffDays} ${diffDays === 1 ? 'day' : 'days'} ago`;
  } else if (diffMonths < 12) {
    return `${diffMonths} ${diffMonths === 1 ? 'month' : 'months'} ago`;
  } else {
    return `${diffYears} ${diffYears === 1 ? 'year' : 'years'} ago`;
  }
}

/**
 * Format location data for display
 * 
 * @param location - Location data
 * @returns Formatted location string
 */
export function formatLocation(location?: Location): string {
  if (!location) return 'Location unknown';
  
  return `${location.latitude.toFixed(6)}, ${location.longitude.toFixed(6)}`;
}

/**
 * Get approximate address from coordinates using reverse geocoding
 * This is a placeholder that would typically use a geocoding service
 * 
 * @param location - Location data
 * @returns Promise resolving to address string
 */
export async function getAddressFromLocation(location?: Location): Promise<string> {
  if (!location) return 'Location unknown';
  
  // In a real implementation, this would call a geocoding service
  // For now, we'll return the coordinates in a readable format
  return `Latitude: ${location.latitude.toFixed(4)}, Longitude: ${location.longitude.toFixed(4)}`;
}

/**
 * Group collection items by a specific property
 * 
 * @param items - Collection items to group
 * @param property - Property to group by (e.g., 'family', 'genus')
 * @returns Grouped items object
 */
export function groupItemsByProperty(
  items: CollectionItem[],
  property: 'family' | 'genus' | 'scientificName'
): Record<string, CollectionItem[]> {
  return items.reduce((groups, item) => {
    const key = item[property] || 'Unknown';
    if (!groups[key]) {
      groups[key] = [];
    }
    groups[key].push(item);
    return groups;
  }, {} as Record<string, CollectionItem[]>);
}

/**
 * Group collection items by custom tags
 * 
 * @param items - Collection items to group
 * @returns Grouped items by tag
 */
export function groupItemsByTags(items: CollectionItem[]): Record<string, CollectionItem[]> {
  const result: Record<string, CollectionItem[]> = {};
  
  items.forEach(item => {
    if (!item.tags || item.tags.length === 0) {
      if (!result['Untagged']) {
        result['Untagged'] = [];
      }
      result['Untagged'].push(item);
      return;
    }
    
    item.tags.forEach(tag => {
      if (!result[tag]) {
        result[tag] = [];
      }
      result[tag].push(item);
    });
  });
  
  return result;
}

/**
 * Sort collection items by date
 * 
 * @param items - Collection items to sort
 * @param order - Sort order ('asc' or 'desc')
 * @returns Sorted items array
 */
export function sortItemsByDate(
  items: CollectionItem[],
  order: 'asc' | 'desc' = 'desc'
): CollectionItem[] {
  return [...items].sort((a, b) => {
    const dateA = new Date(a.collectedAt).getTime();
    const dateB = new Date(b.collectedAt).getTime();
    
    return order === 'asc' ? dateA - dateB : dateB - dateA;
  });
}

/**
 * Sort collections by item count
 * 
 * @param collections - Collections to sort
 * @param order - Sort order ('asc' or 'desc')
 * @returns Sorted collections array
 */
export function sortCollectionsByItemCount(
  collections: PlantCollection[],
  order: 'asc' | 'desc' = 'desc'
): PlantCollection[] {
  return [...collections].sort((a, b) => {
    return order === 'asc' ? a.itemCount - b.itemCount : b.itemCount - a.itemCount;
  });
}

/**
 * Filter collection items by date range
 * 
 * @param items - Collection items to filter
 * @param startDate - Start date of range
 * @param endDate - End date of range
 * @returns Filtered items array
 */
export function filterItemsByDateRange(
  items: CollectionItem[],
  startDate: Date,
  endDate: Date
): CollectionItem[] {
  return items.filter(item => {
    const itemDate = new Date(item.collectedAt);
    return itemDate >= startDate && itemDate <= endDate;
  });
}

/**
 * Filter collection items by location proximity
 * 
 * @param items - Collection items to filter
 * @param targetLocation - Target location
 * @param radiusKm - Radius in kilometers
 * @returns Filtered items array
 */
export function filterItemsByLocationProximity(
  items: CollectionItem[],
  targetLocation: Location,
  radiusKm: number
): CollectionItem[] {
  return items.filter(item => {
    if (!item.location) return false;
    
    // Calculate distance using Haversine formula
    const distance = calculateDistance(
      item.location.latitude,
      item.location.longitude,
      targetLocation.latitude,
      targetLocation.longitude
    );
    
    return distance <= radiusKm;
  });
}

/**
 * Calculate distance between two coordinates using Haversine formula
 * 
 * @param lat1 - Latitude of first point
 * @param lon1 - Longitude of first point
 * @param lat2 - Latitude of second point
 * @param lon2 - Longitude of second point
 * @returns Distance in kilometers
 */
export function calculateDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371; // Earth's radius in km
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) * 
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c;
  
  return distance;
}

/**
 * Convert degrees to radians
 * 
 * @param degrees - Angle in degrees
 * @returns Angle in radians
 */
function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}

/**
 * Generate metadata summary for a collection item
 * 
 * @param item - Collection item
 * @returns Metadata summary string
 */
export function generateItemMetadataSummary(item: CollectionItem): string {
  const parts = [];
  
  if (item.family) {
    parts.push(`Family: ${item.family}`);
  }
  
  if (item.genus) {
    parts.push(`Genus: ${item.genus}`);
  }
  
  parts.push(`Added: ${formatRelativeTime(item.collectedAt)}`);
  
  if (item.location) {
    parts.push(`Location: ${formatLocation(item.location)}`);
  }
  
  return parts.join(' • ');
}

/**
 * Create a search index for collection items
 * Enables efficient text search across multiple fields
 * 
 * @param items - Collection items to index
 * @returns Search index mapping item IDs to searchable text
 */
export function createSearchIndex(items: CollectionItem[]): Record<string, string> {
  const searchIndex: Record<string, string> = {};
  
  items.forEach(item => {
    // Combine all searchable fields into a single string
    const searchableText = [
      item.scientificName,
      ...(item.commonNames || []),
      item.family,
      item.genus,
      item.description,
      ...(item.tags || []),
      item.notes
    ]
      .filter(Boolean) // Remove null/undefined values
      .join(' ')
      .toLowerCase();
    
    searchIndex[item.id] = searchableText;
  });
  
  return searchIndex;
}

/**
 * Search collection items using the search index
 * 
 * @param items - Collection items to search
 * @param searchIndex - Search index created with createSearchIndex
 * @param query - Search query
 * @returns Matching collection items
 */
export function searchItems(
  items: CollectionItem[],
  searchIndex: Record<string, string>,
  query: string
): CollectionItem[] {
  const normalizedQuery = query.toLowerCase().trim();
  
  if (!normalizedQuery) {
    return items;
  }
  
  // Find items whose search text contains the query
  return items.filter(item => {
    const searchText = searchIndex[item.id];
    return searchText && searchText.includes(normalizedQuery);
  });
}