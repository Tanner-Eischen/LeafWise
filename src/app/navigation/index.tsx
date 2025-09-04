/**
 * Navigation structure for LeafWise application
 * Implements authentication-aware routing and tab navigation
 * Provides seamless user experience across features
 */

import React, { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';

// Auth screens
import { LoginScreen, RegisterScreen, PasswordResetScreen } from '../../features/auth/screens';

// Main app screens
import { ProfileScreen } from '../../features/profile/screens';
import { CollectionGridDemoScreen, PlantDetailViewDemoScreen } from '../../features/collection/screens';
import { 
  IdentificationResultsScreen, 
  IdentificationWithAlternativesScreen,
  AlternativeMatchesScreen
} from '../../features/identification/screens';

// Types
import { RootStackParamList, AuthStackParamList, MainTabParamList, CollectionStackParamList, IdentificationStackParamList } from './types';

// Create navigators
const RootStack = createNativeStackNavigator<RootStackParamList>();
const AuthStack = createNativeStackNavigator<AuthStackParamList>();
const MainTab = createBottomTabNavigator<MainTabParamList>();
const CollectionStack = createNativeStackNavigator<CollectionStackParamList>();
const IdentificationStack = createNativeStackNavigator<IdentificationStackParamList>();

/**
 * Authentication stack navigator
 * Contains screens for login, registration, and password reset
 */
function AuthNavigator() {
  return (
    <AuthStack.Navigator
      screenOptions={{
        headerShown: true,
        headerStyle: {
          backgroundColor: '#4a7c4a',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      }}
    >
      <AuthStack.Screen 
        name="Login" 
        component={LoginScreen} 
        options={{ title: 'Sign In' }} 
      />
      <AuthStack.Screen 
        name="Register" 
        component={RegisterScreen} 
        options={{ title: 'Create Account' }} 
      />
      <AuthStack.Screen 
        name="PasswordReset" 
        component={PasswordResetScreen} 
        options={{ title: 'Reset Password' }} 
      />
    </AuthStack.Navigator>
  );
}

/**
 * Collection stack navigator
 * Contains screens for viewing and managing plant collections
 */
function CollectionNavigator() {
  return (
    <CollectionStack.Navigator>
      <CollectionStack.Screen 
        name="CollectionGrid" 
        component={CollectionGridDemoScreen} 
        options={{ title: 'My Collections' }} 
      />
      <CollectionStack.Screen 
        name="PlantDetail" 
        component={PlantDetailViewDemoScreen} 
        options={{ title: 'Plant Details' }} 
      />
    </CollectionStack.Navigator>
  );
}

/**
 * Identification stack navigator
 * Contains screens for plant identification flow
 */
function IdentificationNavigator() {
  return (
    <IdentificationStack.Navigator>
      <IdentificationStack.Screen 
        name="IdentificationResults" 
        component={IdentificationResultsScreen} 
        options={{ title: 'Identification Results' }} 
      />
      <IdentificationStack.Screen 
        name="IdentificationWithAlternatives" 
        component={IdentificationWithAlternativesScreen} 
        options={{ title: 'Identification Results' }} 
      />
      <IdentificationStack.Screen 
        name="AlternativeMatches" 
        component={AlternativeMatchesScreen} 
        options={{ title: 'Alternative Matches' }} 
      />
    </IdentificationStack.Navigator>
  );
}

/**
 * Main tab navigator
 * Contains tabs for the main app features
 */
function MainNavigator() {
  return (
    <MainTab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName;

          if (route.name === 'Collection') {
            iconName = focused ? 'leaf' : 'leaf-outline';
          } else if (route.name === 'Identify') {
            iconName = focused ? 'camera' : 'camera-outline';
          } else if (route.name === 'Profile') {
            iconName = focused ? 'person' : 'person-outline';
          }

          return <Ionicons name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#2d5a2d',
        tabBarInactiveTintColor: 'gray',
        headerShown: false,
      })}
    >
      <MainTab.Screen name="Collection" component={CollectionNavigator} />
      <MainTab.Screen name="Identify" component={IdentificationNavigator} />
      <MainTab.Screen name="Profile" component={ProfileScreen} />
    </MainTab.Navigator>
  );
}

/**
 * Root navigator component
 * Handles authentication state and renders appropriate navigator
 */
export function AppNavigator() {
  const [isLoading, setIsLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // Simulate authentication check
  useEffect(() => {
    // In a real app, this would check for a valid auth token
    const checkAuthStatus = async () => {
      try {
        // Simulate API call delay
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // For demo purposes, we'll default to authenticated
        // In a real app, this would be determined by auth state
        setIsAuthenticated(true);
      } catch (error) {
        console.error('Auth check failed:', error);
        setIsAuthenticated(false);
      } finally {
        setIsLoading(false);
      }
    };

    checkAuthStatus();
  }, []);

  // Show loading screen while checking auth status
  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4a7c4a" />
        <Text style={styles.loadingText}>Loading LeafWise...</Text>
      </View>
    );
  }

  return (
    <NavigationContainer>
      <RootStack.Navigator screenOptions={{ headerShown: false }}>
        {isAuthenticated ? (
          <RootStack.Screen name="Main" component={MainNavigator} />
        ) : (
          <RootStack.Screen name="Auth" component={AuthNavigator} />
        )}
      </RootStack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f0f8f0',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#4a7c4a',
  },
});

export default AppNavigator;