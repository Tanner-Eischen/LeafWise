/**
 * Lighting Guidance Component
 * 
 * This component provides real-time lighting guidance to users during plant photography.
 * It displays lighting conditions, recommendations, and visual indicators to help users
 * capture optimal photos for plant identification.
 * 
 * Features:
 * - Real-time lighting condition display
 * - Flash recommendations
 * - Visual lighting indicators
 * - Actionable guidance messages
 * - Automatic monitoring with cleanup
 */

import React, { useEffect, useState, useCallback, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Animated,
  TouchableOpacity,
  Alert,
} from 'react-native';
import {
  analyzeLightingConditions,
  createLightingMonitor,
  type LightingAnalysis,
  type LightingCondition,
  type LightingDetectionConfig,
} from '../utils/lightingDetection';
import { JSX } from 'react/jsx-dev-runtime';

/**
 * Props for the LightingGuidance component
 */
export interface LightingGuidanceProps {
  /** Whether to show the guidance overlay */
  visible?: boolean;
  /** Configuration for lighting detection */
  config?: Partial<LightingDetectionConfig>;
  /** Callback when flash recommendation changes */
  onFlashRecommendationChange?: (recommendation: string) => void;
  /** Callback when lighting suitability changes */
  onSuitabilityChange?: (suitable: boolean) => void;
  /** Whether to show detailed recommendations */
  showDetailedRecommendations?: boolean;
  /** Custom styling */
  style?: object;
  /** Test ID for testing */
  testID?: string;
}

/**
 * Color scheme for different lighting conditions
 */
const CONDITION_COLORS = {
  excellent: '#4CAF50', // Green
  good: '#8BC34A',      // Light Green
  fair: '#FFC107',      // Amber
  poor: '#FF9800',      // Orange
  'very-poor': '#F44336', // Red
} as const;

/**
 * Icons for different lighting conditions (using text for simplicity)
 */
const CONDITION_ICONS = {
  excellent: '☀️',
  good: '🌤️',
  fair: '⛅',
  poor: '🌥️',
  'very-poor': '🌑',
} as const;

/**
 * LightingGuidance Component
 * 
 * Provides real-time lighting guidance and recommendations for optimal plant photography
 */
export function LightingGuidance({
  visible = true,
  config,
  onFlashRecommendationChange,
  onSuitabilityChange,
  showDetailedRecommendations = false,
  style,
  testID = 'lighting-guidance',
}: LightingGuidanceProps): JSX.Element | null {
  const [lightingAnalysis, setLightingAnalysis] = useState<LightingAnalysis | null>(null);
  const [isMonitoring, setIsMonitoring] = useState(false);
  const [showRecommendations, setShowRecommendations] = useState(false);
  
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const pulseAnim = useRef(new Animated.Value(1)).current;
  const stopMonitorRef = useRef<(() => void) | null>(null);

  /**
   * Handles lighting analysis updates from the monitor
   */
  const handleLightingUpdate = useCallback((analysis: LightingAnalysis) => {
    setLightingAnalysis(analysis);
    
    // Notify parent components of changes
    onFlashRecommendationChange?.(analysis.flashRecommendation);
    onSuitabilityChange?.(analysis.isSuitableForPhotography);
    
    // Trigger pulse animation for poor conditions
    if (analysis.condition === 'poor' || analysis.condition === 'very-poor') {
      Animated.sequence([
        Animated.timing(pulseAnim, {
          toValue: 1.2,
          duration: 300,
          useNativeDriver: true,
        }),
        Animated.timing(pulseAnim, {
          toValue: 1,
          duration: 300,
          useNativeDriver: true,
        }),
      ]).start();
    }
  }, [onFlashRecommendationChange, onSuitabilityChange, pulseAnim]);

  /**
   * Starts lighting monitoring
   */
  const startMonitoring = useCallback(() => {
    if (isMonitoring) return;
    
    setIsMonitoring(true);
    stopMonitorRef.current = createLightingMonitor(handleLightingUpdate, config);
  }, [isMonitoring, handleLightingUpdate, config]);

  /**
   * Stops lighting monitoring
   */
  const stopMonitoring = useCallback(() => {
    if (!isMonitoring) return;
    
    setIsMonitoring(false);
    stopMonitorRef.current?.();
    stopMonitorRef.current = null;
  }, [isMonitoring]);

  /**
   * Toggles detailed recommendations display
   */
  const toggleRecommendations = useCallback(() => {
    setShowRecommendations(prev => !prev);
  }, []);

  /**
   * Shows detailed guidance in an alert
   */
  const showDetailedGuidance = useCallback(() => {
    if (!lightingAnalysis) return;
    
    const { condition, recommendations } = lightingAnalysis;
    const title = `${CONDITION_ICONS[condition]} ${condition.charAt(0).toUpperCase() + condition.slice(1)} Lighting`;
    const message = recommendations.join('\n\n');
    
    Alert.alert(title, message, [{ text: 'OK' }]);
  }, [lightingAnalysis]);

  // Start/stop monitoring based on visibility
  useEffect(() => {
    if (visible) {
      startMonitoring();
      
      // Fade in animation
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }).start();
    } else {
      stopMonitoring();
      
      // Fade out animation
      Animated.timing(fadeAnim, {
        toValue: 0,
        duration: 300,
        useNativeDriver: true,
      }).start();
    }
    
    return () => {
      stopMonitoring();
    };
  }, [visible, startMonitoring, stopMonitoring, fadeAnim]);

  // Don't render if not visible or no analysis yet
  if (!visible || !lightingAnalysis) {
    return null;
  }

  const {
    condition,
    lightLevel,
    flashRecommendation,
    guidance,
    isSuitableForPhotography,
    recommendations,
  } = lightingAnalysis;

  const conditionColor = CONDITION_COLORS[condition];
  const conditionIcon = CONDITION_ICONS[condition];

  return (
    <Animated.View
      style={[
        styles.container,
        { opacity: fadeAnim },
        style,
      ]}
      testID={testID}
    >
      <Animated.View
        style={[
          styles.mainIndicator,
          { backgroundColor: conditionColor, transform: [{ scale: pulseAnim }] },
        ]}
      >
        <TouchableOpacity
          style={styles.indicatorContent}
          onPress={showDetailedGuidance}
          testID={`${testID}-main-indicator`}
        >
          <Text style={styles.conditionIcon}>{conditionIcon}</Text>
          <Text style={styles.conditionText}>
            {condition.charAt(0).toUpperCase() + condition.slice(1)}
          </Text>
          <Text style={styles.lightLevelText}>{lightLevel}%</Text>
        </TouchableOpacity>
      </Animated.View>

      <View style={styles.guidanceContainer}>
        <Text style={styles.guidanceText} testID={`${testID}-guidance`}>
          {guidance}
        </Text>
        
        {flashRecommendation !== 'none' && (
          <View style={styles.flashRecommendation}>
            <Text style={styles.flashText}>
              💡 Flash: {flashRecommendation.charAt(0).toUpperCase() + flashRecommendation.slice(1)}
            </Text>
          </View>
        )}
        
        {!isSuitableForPhotography && (
          <View style={styles.warningContainer}>
            <Text style={styles.warningText}>
              ⚠️ Lighting may affect photo quality
            </Text>
          </View>
        )}
      </View>

      {(showDetailedRecommendations || showRecommendations) && (
        <View style={styles.recommendationsContainer}>
          <TouchableOpacity
            style={styles.recommendationsHeader}
            onPress={toggleRecommendations}
            testID={`${testID}-recommendations-toggle`}
          >
            <Text style={styles.recommendationsTitle}>
              Recommendations {showRecommendations ? '▼' : '▶'}
            </Text>
          </TouchableOpacity>
          
          {showRecommendations && (
            <View style={styles.recommendationsList} testID={`${testID}-recommendations-list`}>
              {recommendations.map((recommendation, index) => (
                <Text key={index} style={styles.recommendationItem}>
                  • {recommendation}
                </Text>
              ))}
            </View>
          )}
        </View>
      )}
    </Animated.View>
  );
}

/**
 * Styles for the LightingGuidance component
 */
const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 20,
    left: 20,
    right: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    borderRadius: 12,
    padding: 16,
    zIndex: 1000,
  },
  mainIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: 8,
    marginBottom: 12,
  },
  indicatorContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    flex: 1,
  },
  conditionIcon: {
    fontSize: 24,
    marginRight: 8,
  },
  conditionText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
    flex: 1,
  },
  lightLevelText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '500',
  },
  guidanceContainer: {
    marginBottom: 8,
  },
  guidanceText: {
    color: 'white',
    fontSize: 14,
    lineHeight: 20,
    marginBottom: 8,
  },
  flashRecommendation: {
    backgroundColor: 'rgba(255, 193, 7, 0.2)',
    borderRadius: 6,
    padding: 8,
    marginBottom: 8,
  },
  flashText: {
    color: '#FFC107',
    fontSize: 13,
    fontWeight: '500',
  },
  warningContainer: {
    backgroundColor: 'rgba(244, 67, 54, 0.2)',
    borderRadius: 6,
    padding: 8,
    marginBottom: 8,
  },
  warningText: {
    color: '#F44336',
    fontSize: 13,
    fontWeight: '500',
  },
  recommendationsContainer: {
    borderTopWidth: 1,
    borderTopColor: 'rgba(255, 255, 255, 0.2)',
    paddingTop: 12,
  },
  recommendationsHeader: {
    paddingVertical: 4,
  },
  recommendationsTitle: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  recommendationsList: {
    marginTop: 8,
  },
  recommendationItem: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 13,
    lineHeight: 18,
    marginBottom: 4,
  },
});

export default LightingGuidance;