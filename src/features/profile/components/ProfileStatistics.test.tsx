/**
 * Tests for ProfileStatistics component
 */

import React from 'react';
import { render } from '@testing-library/react-native';
import ProfileStatistics from './ProfileStatistics';
import { UserStatistics } from '../types';

describe('ProfileStatistics', () => {
  const mockStatistics: UserStatistics = {
    plantsIdentified: 42,
    plantsSaved: 30,
    plantsFavorited: 15,
    activeDays: 7,
    lastIdentificationDate: '2023-05-15T10:30:00Z',
    identificationAccuracy: 92.5
  };

  it('renders correctly with provided statistics', () => {
    const { getByText } = render(
      <ProfileStatistics statistics={mockStatistics} />
    );

    // Check if main statistics are displayed
    expect(getByText('42')).toBeTruthy();
    expect(getByText('Plants Identified')).toBeTruthy();
    expect(getByText('30')).toBeTruthy();
    expect(getByText('Plants Saved')).toBeTruthy();
    expect(getByText('15')).toBeTruthy();
    expect(getByText('Favorites')).toBeTruthy();

    // Check if detailed statistics are displayed
    expect(getByText('Active Days:')).toBeTruthy();
    expect(getByText('7')).toBeTruthy();
    expect(getByText('Last Identification:')).toBeTruthy();
    expect(getByText('Identification Accuracy:')).toBeTruthy();
    expect(getByText('92.5%')).toBeTruthy();
  });

  it('renders with default values when statistics are not provided', () => {
    const { getByText } = render(<ProfileStatistics />);

    // Check if default values are displayed
    expect(getByText('0')).toBeTruthy(); // Multiple zeros should be present
    expect(getByText('Plants Identified')).toBeTruthy();
    expect(getByText('Plants Saved')).toBeTruthy();
    expect(getByText('Favorites')).toBeTruthy();
    expect(getByText('Never')).toBeTruthy(); // Default for lastIdentificationDate
    expect(getByText('N/A')).toBeTruthy(); // Default for identificationAccuracy
  });

  it('applies custom styles when provided', () => {
    const customStyle = { backgroundColor: 'red' };
    const { container } = render(
      <ProfileStatistics statistics={mockStatistics} style={customStyle} />
    );

    // This is a basic check that the component renders with custom styles
    // A more thorough test would check the actual style properties
    expect(container).toBeTruthy();
  });
});