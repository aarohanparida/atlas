import 'package:flutter/material.dart';

import '../../widgets/permission_screen.dart';
import 'notifications_permission_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionScreen(
      iconPath: 'assets/images/location.svg',

      title: 'Remember\nwhere it happened.',

      subtitle:
          'Atlas uses your location to organize trips, restaurants, vacations, and other places you visit.',

      buttonText: 'Allow Location',

      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationsPermissionScreen(),
          ),
        );
      },
    );
  }
}