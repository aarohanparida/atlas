import 'package:flutter/material.dart';

import '../../widgets/permission_screen.dart';
import 'calendar_permission_screen.dart';

class PhotosPermissionScreen extends StatelessWidget {
  const PhotosPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionScreen(
      iconPath: 'assets/images/camera.svg',

      title: 'Your photos are\nyour memories.',

      subtitle:
          'Atlas uses your photos to build your timeline.',

      buttonText: 'Allow Photos',

      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CalendarPermissionScreen(),
          ),
        );
      },
    );
  }
}