import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'create_memory_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Timeline", style: AppText.title),
        backgroundColor: AppColors.background,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "My Timeline",
            style: AppText.title.copyWith(fontSize: 20),
          ),

          const SizedBox(height: 8),

          const ListTile(
            leading: Icon(Icons.photo),
            title: Text("Beach Trip"),
            subtitle: Text("July 5, 2026"),
          ),
          const ListTile(
            leading: Icon(Icons.photo),
            title: Text("Robotics Meeting"),
            subtitle: Text("July 3, 2026"),
          ),
          const ListTile(
            leading: Icon(Icons.photo),
            title: Text("Birthday Party"),
            subtitle: Text("June 28, 2026"),
          ),

          const SizedBox(height: 28),

          Text(
            "Shared Timelines",
            style: AppText.title.copyWith(fontSize: 20),
          ),

          const SizedBox(height: 8),

          const ListTile(
            leading: Icon(Icons.groups),
            title: Text("Family"),
            subtitle: Text("486 memories"),
          ),
          const ListTile(
            leading: Icon(Icons.groups),
            title: Text("Basketball"),
            subtitle: Text("64 memories"),
          ),
        ],
      ),
    );
  }
}