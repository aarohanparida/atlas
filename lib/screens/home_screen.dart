import 'package:atlas/widgets/globe_video.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/spinning_globe.dart';
import '../widgets/atlas_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.public),
            selectedIcon: Icon(Icons.public),
            label: 'Shared',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              Text(
                "Good Morning",
                style: AppText.subtitle,
              ),

              const SizedBox(height: 4),



              const SizedBox(height: 4),

              Text(
                "Aarohan",
                style: AppText.title,
              ),

              const SizedBox(height: 24),

              const GlobeVideo(),

              TextField(
                decoration: InputDecoration(
                  hintText: "Search your Atlas...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("New Memory"),
                  onPressed: () {},
                ),
              ),

              const SizedBox(height: 36),

              Text(
                "Recent Memories",
                style: AppText.title.copyWith(fontSize: 24),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: const [

                    MemoryTile(
                      title: "Beach Trip",
                      date: "July 5",
                    ),

                    MemoryTile(
                      title: "Robotics Meeting",
                      date: "July 3",
                    ),

                    MemoryTile(
                      title: "Birthday Party",
                      date: "June 28",
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemoryTile extends StatelessWidget {

  const MemoryTile({
    super.key,
    required this.title,
    required this.date,
  });

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.only(bottom: 16),

      child: ListTile(

        leading: const CircleAvatar(
          child: Icon(Icons.photo),
        ),

        title: Text(title),

        subtitle: Text(date),

        trailing: const Icon(Icons.chevron_right),

      ),
    );
  }
}