/**
 * Tests for ConfidenceScoreVisualizer component
 */

import React from 'react';
import { render } from '@testing-library/react-native';
import ConfidenceScoreVisualizer from './ConfidenceScoreVisualizer';

describe('ConfidenceScoreVisualizer', () => {
  it('renders correctly with high confidence', () => {
    const { getByText } = render(
      <ConfidenceScoreVisualizer confidence={0.85} />
    );
    
    expect(getByText('85%')).toBeTruthy();
    expect(getByText('High Confidence')).toBeTruthy();
  });
  
  it('renders correctly with medium confidence', () => {
    const { getByText } = render(
      <ConfidenceScoreVisualizer confidence={0.55} />
    );
    
    expect(getByText('55%')).toBeTruthy();
    expect(getByText('Medium Confidence')).toBeTruthy();
  });
  
  it('renders correctly with low confidence', () => {
    const { getByText } = render(
      <ConfidenceScoreVisualizer confidence={0.25} />
    );
    
    expect(getByText('25%')).toBeTruthy();
    expect(getByText('Low Confidence')).toBeTruthy();
  });
  
  it('handles confidence values outside 0-1 range', () => {
    const { getByText: getByTextHigh } = render(
      <ConfidenceScoreVisualizer confidence={1.5} />
    );
    
    expect(getByTextHigh('100%')).toBeTruthy();
    expect(getByTextHigh('High Confidence')).toBeTruthy();
    
    const { getByText: getByTextLow } = render(
      <ConfidenceScoreVisualizer confidence={-0.5} />
    );
    
    expect(getByTextLow('0%')).toBeTruthy();
    expect(getByTextLow('Low Confidence')).toBeTruthy();
  });
  
  it('hides label when showLabel is false', () => {
    const { queryByText } = render(
      <ConfidenceScoreVisualizer confidence={0.75} showLabel={false} />
    );
    
    expect(queryByText('High Confidence')).toBeNull();
    expect(queryByText('75%')).toBeTruthy();
  });
  
  it('hides percentage when showPercentage is false', () => {
    const { queryByText } = render(
      <ConfidenceScoreVisualizer confidence={0.75} showPercentage={false} />
    );
    
    expect(queryByText('75%')).toBeNull();
    expect(queryByText('High Confidence')).toBeTruthy();
  });
  
  it('applies custom size', () => {
    const { container } = render(
      <ConfidenceScoreVisualizer confidence={0.75} size={120} />
    );
    
    // Check if SVG has the custom size
    const svg = container.findByType('Svg');
    expect(svg.props.width).toBe(120);
    expect(svg.props.height).toBe(120);
  });
});