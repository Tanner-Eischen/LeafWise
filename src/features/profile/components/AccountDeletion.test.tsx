/**
 * Tests for the AccountDeletion component
 */

import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import { AccountDeletion } from './AccountDeletion';
import { authService } from '../../auth/services/AuthService';
import { profileService } from '../services/ProfileService';

// Mock dependencies
jest.mock('@react-navigation/native', () => ({
  useNavigation: () => ({
    reset: jest.fn(),
  }),
}));

jest.mock('../../auth/hooks/useAuth', () => ({
  useAuth: () => ({
    user: { uid: 'test-user-id', email: 'test@example.com' },
    logout: jest.fn(),
  }),
}));

jest.mock('../../auth/services/AuthService', () => ({
  authService: {
    reauthenticate: jest.fn(),
    deleteUserAccount: jest.fn(),
  },
}));

jest.mock('../services/ProfileService', () => ({
  profileService: {
    deleteProfile: jest.fn(),
  },
}));

describe('AccountDeletion', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders the delete account button', () => {
    const { getByText } = render(<AccountDeletion />);
    expect(getByText('Delete Account')).toBeTruthy();
  });

  it('opens the confirmation modal when delete button is pressed', () => {
    const { getByText, queryByText } = render(<AccountDeletion />);
    
    // Modal content should not be visible initially
    expect(queryByText('This action is permanent and cannot be undone')).toBeNull();
    
    // Press delete button
    fireEvent.press(getByText('Delete Account'));
    
    // Modal content should now be visible
    expect(getByText('This action is permanent and cannot be undone')).toBeTruthy();
  });

  it('shows error when password is not provided', () => {
    const { getByText, queryByText } = render(<AccountDeletion />);
    
    // Open modal
    fireEvent.press(getByText('Delete Account'));
    
    // Try to delete without password
    fireEvent.press(getByText('Delete Account').slice(-1)[0]); // Get the second 'Delete Account' button (confirm button)
    
    // Should show error
    expect(getByText('Please enter your password to confirm')).toBeTruthy();
  });

  it('calls the necessary services when account deletion is confirmed', async () => {
    const { getByText, getByPlaceholderText } = render(<AccountDeletion />);
    
    // Open modal
    fireEvent.press(getByText('Delete Account'));
    
    // Enter password
    fireEvent.changeText(getByPlaceholderText('Password'), 'password123');
    
    // Confirm deletion
    fireEvent.press(getByText('Delete Account').slice(-1)[0]); // Get the second 'Delete Account' button (confirm button)
    
    // Verify services were called
    await waitFor(() => {
      expect(authService.reauthenticate).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
      expect(profileService.deleteProfile).toHaveBeenCalledWith('test-user-id');
      expect(authService.deleteUserAccount).toHaveBeenCalled();
    });
  });

  it('handles authentication error during account deletion', async () => {
    // Mock reauthenticate to throw an error
    (authService.reauthenticate as jest.Mock).mockRejectedValueOnce({
      message: 'Invalid password',
    });
    
    const { getByText, getByPlaceholderText } = render(<AccountDeletion />);
    
    // Open modal
    fireEvent.press(getByText('Delete Account'));
    
    // Enter password
    fireEvent.changeText(getByPlaceholderText('Password'), 'wrong-password');
    
    // Confirm deletion
    fireEvent.press(getByText('Delete Account').slice(-1)[0]); // Get the second 'Delete Account' button (confirm button)
    
    // Verify error is displayed
    await waitFor(() => {
      expect(getByText('Invalid password')).toBeTruthy();
    });
    
    // Verify profile deletion was not called
    expect(profileService.deleteProfile).not.toHaveBeenCalled();
    expect(authService.deleteUserAccount).not.toHaveBeenCalled();
  });
});