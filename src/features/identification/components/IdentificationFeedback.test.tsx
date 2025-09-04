/**
 * Tests for IdentificationFeedback component
 */

import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import IdentificationFeedback from './IdentificationFeedback';
import { PlantIdError } from '../../../core/types/plantIdentification';

describe('IdentificationFeedback', () => {
  const mockError: PlantIdError = {
    code: 'NO_PLANT_DETECTED',
    message: 'No plant was detected in the image',
    details: 'The image does not contain a recognizable plant',
    timestamp: new Date().toISOString(),
    recoverable: true,
  };

  const mockImageUri = 'file:///mock/image/path.jpg';
  const mockRetakePhoto = jest.fn();
  const mockRetryIdentification = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders correctly with error', () => {
    const { getByText, getByTestId } = render(
      <IdentificationFeedback 
        error={mockError}
        onRetakePhoto={mockRetakePhoto}
        onRetryIdentification={mockRetryIdentification}
      />
    );

    // Check if the component renders the error message
    expect(getByText('Identification Failed')).toBeTruthy();
    expect(getByText(mockError.message)).toBeTruthy();
    expect(getByTestId('identification-feedback')).toBeTruthy();
  });

  it('renders image when imageUri is provided', () => {
    const { getByTestId } = render(
      <IdentificationFeedback 
        error={mockError}
        imageUri={mockImageUri}
        onRetakePhoto={mockRetakePhoto}
        onRetryIdentification={mockRetryIdentification}
      />
    );

    // The image should be rendered
    const image = getByTestId('identification-feedback').findByProps({
      source: { uri: mockImageUri }
    });
    expect(image).toBeTruthy();
  });

  it('calls onRetakePhoto when Take New Photo button is pressed', () => {
    const { getByText } = render(
      <IdentificationFeedback 
        error={mockError}
        onRetakePhoto={mockRetakePhoto}
        onRetryIdentification={mockRetryIdentification}
      />
    );

    // Press the Take New Photo button
    fireEvent.press(getByText('Take New Photo'));
    expect(mockRetakePhoto).toHaveBeenCalledTimes(1);
  });

  it('calls onRetryIdentification when Retry with Same Photo button is pressed', () => {
    const { getByText } = render(
      <IdentificationFeedback 
        error={mockError}
        onRetakePhoto={mockRetakePhoto}
        onRetryIdentification={mockRetryIdentification}
      />
    );

    // Press the Retry with Same Photo button
    fireEvent.press(getByText('Retry with Same Photo'));
    expect(mockRetryIdentification).toHaveBeenCalledTimes(1);
  });

  it('renders different suggestions based on error code', () => {
    // Test with LOW_CONFIDENCE error
    const lowConfidenceError: PlantIdError = {
      ...mockError,
      code: 'LOW_CONFIDENCE',
      message: 'Low confidence in identification results',
    };

    const { getByText, rerender } = render(
      <IdentificationFeedback error={lowConfidenceError} />
    );

    // Check for composition and focus suggestions
    expect(getByText('Center the Plant')).toBeTruthy();
    expect(getByText('Ensure Sharp Focus')).toBeTruthy();

    // Test with POOR_IMAGE_QUALITY error
    const poorQualityError: PlantIdError = {
      ...mockError,
      code: 'POOR_IMAGE_QUALITY',
      message: 'The image quality is too low for accurate identification',
    };

    rerender(<IdentificationFeedback error={poorQualityError} />);

    // Check for lighting suggestions
    expect(getByText('Improve Lighting')).toBeTruthy();
  });

  it('returns null when no error is provided', () => {
    const { container } = render(<IdentificationFeedback error={null} />);
    expect(container.children.length).toBe(0);
  });
});