import 'package:flutter/material.dart';

import '../../widgets/permission_screen.dart';

class NotificationsPermissionScreen extends StatelessWidget {
  const NotificationsPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionScreen(
      iconPath: 'assets/images/bell.svg',

      title: 'Never miss\na memory.',

      subtitle:
          'Atlas reminds you about anniversaries and special moments.',

      buttonText: 'Enable Notifications',

      onPressed: () {
        // Go to Home
      },
    );
  }
}