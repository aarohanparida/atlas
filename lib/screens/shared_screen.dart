import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class SharedScreen extends StatelessWidget {
  const SharedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Shared Timelines", style: AppText.title),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.groups),
            title: Text("Family"),
            subtitle: Text("486 memories"),
          ),
          ListTile(
            leading: Icon(Icons.groups),
            title: Text("Basketball"),
            subtitle: Text("64 memories"),
          ),
        ],
      ),
    );
  }
}