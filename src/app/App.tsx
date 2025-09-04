/**
 * Main application component for LeafWise
 * Serves as the root component that initializes providers and navigation
 * Follows AI-first development principles with modular, clean architecture
 */

import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet } from 'react-native';
import type { JSX } from 'react';
import { AppNavigator } from './navigation';
import { firebaseApp } from './firebase';

/**
 * Root application component
 * Initializes the app with providers and navigation setup
 * @returns {JSX.Element} The main app component
 */
function App(): JSX.Element {
  // Ensure Firebase is initialized when the app starts
  useEffect(() => {
    // Firebase is already initialized in the firebase.ts file
    // The import of firebaseApp ensures this happens
    console.log('Firebase initialized:', firebaseApp.name);
  }, []);

  return (
    <>
      <AppNavigator />
      <StatusBar style="auto" />
    </>
  );
}

// Styles not needed in the main App component as they're defined in the navigation components
const styles = StyleSheet.create({});


export default App;