/**
 * IdentificationFeedback Component
 * 
 * This component provides feedback and suggestions when plant identification fails or has low confidence.
 * It offers guidance on how to take better photos for more accurate plant identification,
 * including lighting, distance, angle, and focus recommendations.
 * 
 * Features:
 * - Contextual feedback based on identification errors
 * - Photography improvement suggestions
 * - Visual guidance indicators
 * - Actionable retry options
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Image,
} from 'react-native';
import { PlantIdError } from '../../../core/types/plantIdentification';

/**
 * Props for the IdentificationFeedback component
 */
export interface IdentificationFeedbackProps {
  /** The error that occurred during identification */
  error: PlantIdError | null;
  /** The image data that was used for identification */
  imageUri?: string;
  /** Callback function when user wants to retry with a new photo */
  onRetakePhoto?: () => void;
  /** Callback function when user wants to retry identification with the same photo */
  onRetryIdentification?: () => void;
  /** Custom styling */
  style?: object;
  /** Test ID for testing */
  testID?: string;
}

/**
 * Categories of feedback suggestions
 */
type SuggestionCategory = 'lighting' | 'composition' | 'focus' | 'general';

/**
 * Feedback suggestion interface
 */
interface FeedbackSuggestion {
  id: string;
  category: SuggestionCategory;
  title: string;
  description: string;
  icon: string; // Emoji for simplicity
}

/**
 * Predefined feedback suggestions for different scenarios
 */
const FEEDBACK_SUGGESTIONS: Record<string, FeedbackSuggestion[]> = {
  // Suggestions for lighting issues
  lighting: [
    {
      id: 'lighting-1',
      category: 'lighting',
      title: 'Improve Lighting',
      description: 'Take photos in natural daylight. Avoid direct sunlight that creates harsh shadows.',
      icon: '☀️',
    },
    {
      id: 'lighting-2',
      category: 'lighting',
      title: 'Use Flash Appropriately',
      description: 'In low light, use flash to illuminate the plant. In bright conditions, turn it off to prevent overexposure.',
      icon: '⚡',
    },
  ],
  // Suggestions for composition issues
  composition: [
    {
      id: 'composition-1',
      category: 'composition',
      title: 'Center the Plant',
      description: 'Position the plant in the center of the frame to ensure it\'s the main subject.',
      icon: '🎯',
    },
    {
      id: 'composition-2',
      category: 'composition',
      title: 'Capture Multiple Angles',
      description: 'Take photos of leaves, flowers, and the whole plant for better identification.',
      icon: '📐',
    },
    {
      id: 'composition-3',
      category: 'composition',
      title: 'Optimal Distance',
      description: 'Get close enough to show details but not so close that the plant is out of focus.',
      icon: '📏',
    },
  ],
  // Suggestions for focus issues
  focus: [
    {
      id: 'focus-1',
      category: 'focus',
      title: 'Ensure Sharp Focus',
      description: 'Tap on the plant on your screen to focus before taking the photo.',
      icon: '🔍',
    },
    {
      id: 'focus-2',
      category: 'focus',
      title: 'Hold Steady',
      description: 'Keep your device still when taking photos to avoid blur.',
      icon: '✋',
    },
  ],
  // General suggestions
  general: [
    {
      id: 'general-1',
      category: 'general',
      title: 'Clean Lens',
      description: 'Make sure your camera lens is clean and free of smudges or dirt.',
      icon: '🧼',
    },
    {
      id: 'general-2',
      category: 'general',
      title: 'Remove Obstructions',
      description: 'Ensure there are no objects blocking the view of the plant.',
      icon: '✂️',
    },
  ],
};

/**
 * Get relevant suggestions based on error type
 */
function getSuggestionsForError(error: PlantIdError | null): FeedbackSuggestion[] {
  if (!error) return [];
  
  // Default suggestions to include for all errors
  const defaultSuggestions = [
    ...FEEDBACK_SUGGESTIONS.composition,
    ...FEEDBACK_SUGGESTIONS.focus.slice(0, 1),
  ];
  
  // Add specific suggestions based on error code
  switch (error.code) {
    case 'NO_PLANT_DETECTED':
      return [
        ...FEEDBACK_SUGGESTIONS.composition,
        ...FEEDBACK_SUGGESTIONS.general,
      ];
    case 'LOW_CONFIDENCE':
      return [
        ...FEEDBACK_SUGGESTIONS.composition,
        ...FEEDBACK_SUGGESTIONS.focus,
      ];
    case 'POOR_IMAGE_QUALITY':
      return [
        ...FEEDBACK_SUGGESTIONS.lighting,
        ...FEEDBACK_SUGGESTIONS.focus,
        FEEDBACK_SUGGESTIONS.general[0], // Clean lens suggestion
      ];
    case 'NETWORK_ERROR':
      // For network errors, just return a minimal set of suggestions
      return FEEDBACK_SUGGESTIONS.general.slice(0, 1);
    default:
      return defaultSuggestions;
  }
}

/**
 * IdentificationFeedback Component
 * 
 * Provides feedback and suggestions when plant identification fails
 */
export function IdentificationFeedback({
  error,
  imageUri,
  onRetakePhoto,
  onRetryIdentification,
  style,
  testID = 'identification-feedback',
}: IdentificationFeedbackProps): JSX.Element | null {
  // If no error, don't render anything
  if (!error) return null;
  
  // Get relevant suggestions based on the error
  const suggestions = getSuggestionsForError(error);
  
  return (
    <View style={[styles.container, style]} testID={testID}>
      <Text style={styles.title}>Identification Failed</Text>
      <Text style={styles.errorMessage}>{error.message}</Text>
      
      {imageUri && (
        <View style={styles.imageContainer}>
          <Image source={{ uri: imageUri }} style={styles.image} resizeMode="cover" />
        </View>
      )}
      
      <ScrollView style={styles.suggestionsContainer}>
        <Text style={styles.suggestionsTitle}>Photography Tips</Text>
        
        {suggestions.map((suggestion) => (
          <View key={suggestion.id} style={styles.suggestionItem}>
            <Text style={styles.suggestionIcon}>{suggestion.icon}</Text>
            <View style={styles.suggestionContent}>
              <Text style={styles.suggestionTitle}>{suggestion.title}</Text>
              <Text style={styles.suggestionDescription}>{suggestion.description}</Text>
            </View>
          </View>
        ))}
      </ScrollView>
      
      <View style={styles.actionsContainer}>
        {onRetakePhoto && (
          <TouchableOpacity 
            style={[styles.actionButton, styles.primaryButton]} 
            onPress={onRetakePhoto}
            testID="retake-photo-button"
          >
            <Text style={styles.primaryButtonText}>Take New Photo</Text>
          </TouchableOpacity>
        )}
        
        {onRetryIdentification && (
          <TouchableOpacity 
            style={[styles.actionButton, styles.secondaryButton]} 
            onPress={onRetryIdentification}
            testID="retry-identification-button"
          >
            <Text style={styles.secondaryButtonText}>Retry with Same Photo</Text>
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    margin: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#d32f2f',
    marginBottom: 8,
    textAlign: 'center',
  },
  errorMessage: {
    fontSize: 16,
    color: '#666',
    marginBottom: 16,
    textAlign: 'center',
  },
  imageContainer: {
    alignItems: 'center',
    marginBottom: 16,
    borderRadius: 8,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#ddd',
  },
  image: {
    width: '100%',
    height: 200,
    backgroundColor: '#f0f0f0',
  },
  suggestionsContainer: {
    maxHeight: 300,
    marginBottom: 16,
  },
  suggestionsTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 12,
  },
  suggestionItem: {
    flexDirection: 'row',
    marginBottom: 16,
    backgroundColor: '#f9f9f9',
    borderRadius: 8,
    padding: 12,
  },
  suggestionIcon: {
    fontSize: 24,
    marginRight: 12,
    alignSelf: 'center',
  },
  suggestionContent: {
    flex: 1,
  },
  suggestionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2d5a2d',
    marginBottom: 4,
  },
  suggestionDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  actionsContainer: {
    marginTop: 8,
  },
  actionButton: {
    borderRadius: 8,
    padding: 14,
    alignItems: 'center',
    marginBottom: 8,
  },
  primaryButton: {
    backgroundColor: '#2d5a2d',
  },
  primaryButtonText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 16,
  },
  secondaryButton: {
    backgroundColor: '#f0f0f0',
    borderWidth: 1,
    borderColor: '#ddd',
  },
  secondaryButtonText: {
    color: '#666',
    fontWeight: 'bold',
    fontSize: 16,
  },
});

export default IdentificationFeedback;