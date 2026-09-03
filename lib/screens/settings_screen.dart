import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Settings", style: AppText.title),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Privacy"),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("About Atlas"),
          ),
        ],
      ),
    );
  }
}