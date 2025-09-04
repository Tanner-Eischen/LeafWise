/**
 * ProfileStatistics Component
 * Displays user's plant collection statistics in a visually appealing format
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { UserStatistics } from '../types';

interface ProfileStatisticsProps {
  /** User statistics data to display */
  statistics?: UserStatistics;
  /** Optional custom style for the container */
  style?: object;
}

/**
 * Component that displays user's plant collection statistics
 * Shows metrics like plants identified, saved, and favorited
 */
const ProfileStatistics: React.FC<ProfileStatisticsProps> = ({ 
  statistics, 
  style 
}) => {
  // Use empty statistics object if none provided
  const stats = statistics || {
    plantsIdentified: 0,
    plantsSaved: 0,
    plantsFavorited: 0,
    activeDays: 0,
  };

  // Format date string to readable format
  const formatDate = (dateString?: string): string => {
    if (!dateString) return 'Never';
    
    const date = new Date(dateString);
    return date.toLocaleDateString();
  };

  // Format percentage with one decimal place
  const formatPercentage = (value?: number): string => {
    if (value === undefined) return 'N/A';
    return `${value.toFixed(1)}%`;
  };

  return (
    <View style={[styles.container, style]}>
      <Text style={styles.sectionTitle}>Statistics</Text>
      
      <View style={styles.statsContainer}>
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{stats.plantsIdentified}</Text>
          <Text style={styles.statLabel}>Plants Identified</Text>
        </View>
        
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{stats.plantsSaved}</Text>
          <Text style={styles.statLabel}>Plants Saved</Text>
        </View>
        
        <View style={styles.statItem}>
          <Text style={styles.statValue}>{stats.plantsFavorited}</Text>
          <Text style={styles.statLabel}>Favorites</Text>
        </View>
      </View>

      <View style={styles.detailedStatsContainer}>
        <View style={styles.detailedStatRow}>
          <Text style={styles.detailedStatLabel}>Active Days:</Text>
          <Text style={styles.detailedStatValue}>{stats.activeDays}</Text>
        </View>
        
        <View style={styles.detailedStatRow}>
          <Text style={styles.detailedStatLabel}>Last Identification:</Text>
          <Text style={styles.detailedStatValue}>
            {formatDate(stats.lastIdentificationDate)}
          </Text>
        </View>
        
        <View style={styles.detailedStatRow}>
          <Text style={styles.detailedStatLabel}>Identification Accuracy:</Text>
          <Text style={styles.detailedStatValue}>
            {formatPercentage(stats.identificationAccuracy)}
          </Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 16,
    backgroundColor: '#fff',
    borderRadius: 8,
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
    color: '#2e7d32',
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  statItem: {
    alignItems: 'center',
    flex: 1,
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2e7d32',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 4,
  },
  detailedStatsContainer: {
    marginTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#eee',
    paddingTop: 12,
  },
  detailedStatRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  detailedStatLabel: {
    fontSize: 14,
    color: '#666',
  },
  detailedStatValue: {
    fontSize: 14,
    fontWeight: '500',
    color: '#333',
  },
});

export default ProfileStatistics;