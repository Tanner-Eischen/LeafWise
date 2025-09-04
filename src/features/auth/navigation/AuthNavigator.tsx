/**
 * Authentication Navigator
 * Handles navigation between authentication screens
 */

import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { LoginScreen, RegisterScreen, PasswordResetScreen } from '../screens';
import { AuthStackParamList } from '../screens/LoginScreen';

const Stack = createNativeStackNavigator<AuthStackParamList>();

/**
 * Authentication Navigator Component
 * Sets up the navigation stack for authentication screens
 * 
 * @returns {JSX.Element} Authentication navigator component
 */
export function AuthNavigator(): JSX.Element {
  return (
    <Stack.Navigator
      initialRouteName="Login"
      screenOptions={{
        headerShown: false,
        animation: 'slide_from_right',
      }}
    >
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="Register" component={RegisterScreen} />
      <Stack.Screen name="PasswordReset" component={PasswordResetScreen} />
    </Stack.Navigator>
  );
}