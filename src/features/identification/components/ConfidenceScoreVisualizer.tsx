/**
 * ConfidenceScoreVisualizer Component
 * Provides a visual representation of confidence scores for plant identification results
 * Includes circular progress indicator, color coding, and descriptive labels
 */

import React from 'react';
import { View, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';
import Svg, { Circle, Text as SvgText } from 'react-native-svg';

interface ConfidenceScoreVisualizerProps {
  confidence: number;
  size?: number;
  strokeWidth?: number;
  showLabel?: boolean;
  showPercentage?: boolean;
  style?: ViewStyle;
  labelStyle?: TextStyle;
}

/**
 * Get color based on confidence level
 * 
 * @param confidence - Confidence score (0-1)
 * @returns Color string in hex format
 */
const getConfidenceColor = (confidence: number): string => {
  if (confidence >= 0.7) return '#388e3c'; // High confidence - green
  if (confidence >= 0.4) return '#f57c00'; // Medium confidence - orange
  return '#d32f2f'; // Low confidence - red
};

/**
 * Get confidence level label
 * 
 * @param confidence - Confidence score (0-1)
 * @returns Descriptive label for confidence level
 */
const getConfidenceLabel = (confidence: number): string => {
  if (confidence >= 0.7) return 'High';
  if (confidence >= 0.4) return 'Medium';
  return 'Low';
};

/**
 * Component for visualizing confidence scores with circular progress indicator
 * 
 * @param props - Component props
 * @returns Rendered component
 */
function ConfidenceScoreVisualizer({
  confidence,
  size = 80,
  strokeWidth = 8,
  showLabel = true,
  showPercentage = true,
  style,
  labelStyle,
}: ConfidenceScoreVisualizerProps): JSX.Element {
  // Validate confidence value
  const validConfidence = Math.max(0, Math.min(1, confidence));
  
  // Calculate SVG parameters
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const progressValue = validConfidence * circumference;
  const center = size / 2;
  
  // Format confidence as percentage
  const percentage = Math.round(validConfidence * 100);
  
  // Get color and label based on confidence
  const color = getConfidenceColor(validConfidence);
  const label = getConfidenceLabel(validConfidence);
  
  return (
    <View style={[styles.container, style]}>
      <Svg width={size} height={size}>
        {/* Background circle */}
        <Circle
          cx={center}
          cy={center}
          r={radius}
          stroke="#e0e0e0"
          strokeWidth={strokeWidth}
          fill="transparent"
        />
        
        {/* Progress circle */}
        <Circle
          cx={center}
          cy={center}
          r={radius}
          stroke={color}
          strokeWidth={strokeWidth}
          strokeDasharray={circumference}
          strokeDashoffset={circumference - progressValue}
          strokeLinecap="round"
          fill="transparent"
          transform={`rotate(-90, ${center}, ${center})`}
        />
        
        {/* Percentage text */}
        {showPercentage && (
          <SvgText
            x={center}
            y={center + 5}
            fontSize="16"
            fontWeight="bold"
            fill={color}
            textAnchor="middle"
            alignmentBaseline="middle"
          >
            {`${percentage}%`}
          </SvgText>
        )}
      </Svg>
      
      {/* Confidence label */}
      {showLabel && (
        <Text style={[styles.label, { color }, labelStyle]}>
          {label} Confidence
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  label: {
    marginTop: 8,
    fontSize: 14,
    fontWeight: '600',
  },
});

export default ConfidenceScoreVisualizer;