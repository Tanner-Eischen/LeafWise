/**
 * ConfidenceVisualizerDemoScreen
 * Demo screen to showcase the ConfidenceScoreVisualizer component with different confidence levels
 * and customization options
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Slider,
} from 'react-native';
import { ConfidenceScoreVisualizer } from '../components';

function ConfidenceVisualizerDemoScreen(): JSX.Element {
  // State for customizable properties
  const [confidence, setConfidence] = useState(0.75);
  const [size, setSize] = useState(80);
  const [strokeWidth, setStrokeWidth] = useState(8);
  const [showLabel, setShowLabel] = useState(true);
  const [showPercentage, setShowPercentage] = useState(true);

  // Toggle boolean options
  const toggleShowLabel = () => setShowLabel(!showLabel);
  const toggleShowPercentage = () => setShowPercentage(!showPercentage);

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Confidence Score Visualizer</Text>
      
      {/* Main visualizer with current settings */}
      <View style={styles.visualizerContainer}>
        <ConfidenceScoreVisualizer
          confidence={confidence}
          size={size}
          strokeWidth={strokeWidth}
          showLabel={showLabel}
          showPercentage={showPercentage}
        />
      </View>
      
      {/* Controls section */}
      <View style={styles.controlsContainer}>
        <Text style={styles.sectionTitle}>Customize Visualizer</Text>
        
        {/* Confidence slider */}
        <View style={styles.controlRow}>
          <Text style={styles.controlLabel}>Confidence: {Math.round(confidence * 100)}%</Text>
          <Slider
            style={styles.slider}
            minimumValue={0}
            maximumValue={1}
            value={confidence}
            onValueChange={setConfidence}
            minimumTrackTintColor="#4caf50"
            maximumTrackTintColor="#e0e0e0"
          />
        </View>
        
        {/* Size slider */}
        <View style={styles.controlRow}>
          <Text style={styles.controlLabel}>Size: {size}px</Text>
          <Slider
            style={styles.slider}
            minimumValue={40}
            maximumValue={200}
            step={10}
            value={size}
            onValueChange={setSize}
            minimumTrackTintColor="#2196f3"
            maximumTrackTintColor="#e0e0e0"
          />
        </View>
        
        {/* Stroke width slider */}
        <View style={styles.controlRow}>
          <Text style={styles.controlLabel}>Stroke Width: {strokeWidth}px</Text>
          <Slider
            style={styles.slider}
            minimumValue={2}
            maximumValue={20}
            step={1}
            value={strokeWidth}
            onValueChange={setStrokeWidth}
            minimumTrackTintColor="#2196f3"
            maximumTrackTintColor="#e0e0e0"
          />
        </View>
        
        {/* Toggle options */}
        <View style={styles.toggleContainer}>
          <TouchableOpacity
            style={[styles.toggleButton, showLabel ? styles.toggleActive : {}]}
            onPress={toggleShowLabel}
          >
            <Text style={styles.toggleText}>Show Label</Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={[styles.toggleButton, showPercentage ? styles.toggleActive : {}]}
            onPress={toggleShowPercentage}
          >
            <Text style={styles.toggleText}>Show Percentage</Text>
          </TouchableOpacity>
        </View>
      </View>
      
      {/* Preset examples */}
      <View style={styles.presetsContainer}>
        <Text style={styles.sectionTitle}>Confidence Level Examples</Text>
        
        <View style={styles.presetRow}>
          <View style={styles.presetItem}>
            <Text style={styles.presetLabel}>High</Text>
            <ConfidenceScoreVisualizer confidence={0.85} size={60} />
          </View>
          
          <View style={styles.presetItem}>
            <Text style={styles.presetLabel}>Medium</Text>
            <ConfidenceScoreVisualizer confidence={0.55} size={60} />
          </View>
          
          <View style={styles.presetItem}>
            <Text style={styles.presetLabel}>Low</Text>
            <ConfidenceScoreVisualizer confidence={0.25} size={60} />
          </View>
        </View>
      </View>
      
      {/* Size variations */}
      <View style={styles.presetsContainer}>
        <Text style={styles.sectionTitle}>Size Variations</Text>
        
        <View style={styles.presetRow}>
          <View style={styles.presetItem}>
            <Text style={styles.presetLabel}>Small</Text>
            <ConfidenceScoreVisualizer 
              confidence={0.75} 
              size={40} 
              showLabel={false} 
            />
          </View>
          
          <View style={styles.presetItem}>
            <Text style={styles.presetLabel}>Medium</Text>
            <ConfidenceScoreVisualizer 
              confidence={0.75} 
              size={60} 
              showLabel={false} 
            />
          </View>
          
          <View style={styles.presetItem}>
            <Text style={styles.presetLabel}>Large</Text>
            <ConfidenceScoreVisualizer 
              confidence={0.75} 
              size={80} 
              showLabel={false} 
            />
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2d5a2d',
    marginBottom: 24,
    textAlign: 'center',
  },
  visualizerContainer: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: 24,
    alignItems: 'center',
    marginBottom: 24,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  controlsContainer: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: 16,
    marginBottom: 24,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#2d5a2d',
    marginBottom: 16,
  },
  controlRow: {
    marginBottom: 16,
  },
  controlLabel: {
    fontSize: 14,
    color: '#555',
    marginBottom: 8,
  },
  slider: {
    width: '100%',
    height: 40,
  },
  toggleContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 8,
  },
  toggleButton: {
    backgroundColor: '#e0e0e0',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 4,
  },
  toggleActive: {
    backgroundColor: '#4caf50',
  },
  toggleText: {
    color: '#333',
    fontWeight: '500',
  },
  presetsContainer: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    padding: 16,
    marginBottom: 24,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  presetRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'flex-start',
  },
  presetItem: {
    alignItems: 'center',
  },
  presetLabel: {
    fontSize: 14,
    color: '#555',
    marginBottom: 8,
  },
});

export default ConfidenceVisualizerDemoScreen;