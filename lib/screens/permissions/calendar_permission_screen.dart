import 'package:atlas/screens/permissions/location_permission_screen.dart';
import 'package:flutter/material.dart';

import '../../widgets/permission_screen.dart';

class CalendarPermissionScreen extends StatelessWidget {
  const CalendarPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionScreen(
      iconPath: 'assets/images/calendar.svg',

      title: 'Connect your\ncalendar.',

      subtitle:
          'Atlas links memories to your trips, birthdays, and events.',

      buttonText: 'Allow Calendar',

      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LocationPermissionScreen(),
          ),
        );
      },
    );
  }
}