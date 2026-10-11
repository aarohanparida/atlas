import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';
import '../services/user_service.dart';
import 'auth_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatBirthday(dynamic birthday) {
    DateTime? date;

    if (birthday is Timestamp) {
      date = birthday.toDate();
    } else if (birthday is DateTime) {
      date = birthday;
    }

    if (date == null) {
      return 'Not set';
    }

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _signOut(BuildContext context) async {
    await Auth().signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => AuthScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: UserService().getProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load profile.',
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
            );
          }

          final data = snapshot.data;

          final fullName =
              data?['name'] as String? ?? 'Atlas User';

          final email = firebaseUser?.email ?? 'No email';
          final birthday = data?['birthday'];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    _getInitials(fullName),
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  fullName,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          currentName: fullName,
                          currentBirthday: birthday,
                        ),
                      ),
                    );
                  },
                  child: const Text('Edit Profile'),
                ),

                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ABOUT YOU',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Birthday',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _formatBirthday(birthday),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  leading: const Icon(
                    Icons.settings_outlined,
                  ),
                  title: const Text('Settings'),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),

                const Divider(),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () => _signOut(context),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}