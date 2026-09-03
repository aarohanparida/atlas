import 'package:flutter/material.dart';

import '../services/auth.dart';
import '../services/onboarding_service.dart';

import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/permissions/photos_permission_screen.dart';
import '../screens/main_navigation_screen.dart';

import '../services/user_service.dart';
import '../screens/onboarding/profile_setup_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is NOT logged in
        if (!snapshot.hasData) {
          return AuthScreen();
        }

        // User IS logged in
        return FutureBuilder<bool>(
          future: UserService().profileExists(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final profileExists =
                profileSnapshot.data ?? false;

            if (!profileExists) {
              return const ProfileSetupScreen();
            }

            return FutureBuilder<bool>(
              future: OnboardingService.isComplete(),
              builder: (context, onboardingSnapshot) {
                if (onboardingSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final onboardingComplete =
                    onboardingSnapshot.data ?? false;

                if (onboardingComplete) {
                  return const MainNavigationScreen();
                }

                return const PhotosPermissionScreen();
              },
            );
          },
        );
      },
    );
  }
}