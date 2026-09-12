import 'package:atlas/widgets/globe_video.dart';
import 'package:flutter/material.dart';
 
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'create_memory_screen.dart';
import 'timeline_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import '../services/user_service.dart';
import 'memory_details_screen.dart';

import '../models/atlas_memory.dart';
import '../services/memory_service.dart';
 
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  String _formatMemoryDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColors.background,
 
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
 
              FutureBuilder<String>(
                future: UserService().getFirstName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      '',
                      style: AppText.title,
                    );
                  }

                  return Text(
                    snapshot.data ?? 'User',
                    style: AppText.title,
                  );
                },
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CreateMemoryScreen(),
                      ),
                    );
                  },
                ),
              ),
 
              const SizedBox(height: 36),
 
              Text(
                "Recent Memories",
                style: AppText.title.copyWith(fontSize: 24),
              ),
 
              const SizedBox(height: 16),
 
              Expanded(
                child: StreamBuilder<List<AtlasMemory>>(
                  stream: MemoryService().getRecentMemories(),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Could not load your memories.',
                        ),
                      );
                    }

                    final memories =
                        snapshot.data ?? [];

                    if (memories.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 42,
                              color: Colors.grey.shade400,
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'No memories yet.',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Create your first memory.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: memories.length,

                      itemBuilder: (context, index) {
                        final memory = memories[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemoryDetailsScreen(
                                  memory: memory,
                                ),
                              ),
                            );
                          },
                          child: MemoryTile(
                            title: memory.title,
                            date: _formatMemoryDate(memory.date),
                          ),
                        );
                      },
                    );
                  },
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