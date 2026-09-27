import 'package:flutter/material.dart';

import '../models/atlas_memory.dart';
import '../services/memory_service.dart';
import 'memory_details_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memoryService = MemoryService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Timeline',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<AtlasMemory>>(
        stream: memoryService.getAllMemories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Could not load your timeline.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final memories = snapshot.data ?? [];

          if (memories.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildTimeline(
            context,
            memories,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your timeline is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first memory and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    List<AtlasMemory> memories,
  ) {
    final groupedMemories = <int, Map<int, List<AtlasMemory>>>{};

    for (final memory in memories) {
      final year = memory.date.year;
      final month = memory.date.month;

      groupedMemories.putIfAbsent(
        year,
        () => {},
      );

      groupedMemories[year]!.putIfAbsent(
        month,
        () => [],
      );

      groupedMemories[year]![month]!.add(memory);
    }

    final years = groupedMemories.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        40,
      ),
      itemCount: years.length,
      itemBuilder: (context, yearIndex) {
        final year = years[yearIndex];
        final months = groupedMemories[year]!;

        final sortedMonths = months.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildYearHeader(year),

            const SizedBox(height: 20),

            ...sortedMonths.map(
              (month) {
                final monthMemories = months[month]!;

                return _buildMonthSection(
                  context,
                  month,
                  monthMemories,
                );
              },
            ),

            if (yearIndex != years.length - 1)
              const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildYearHeader(int year) {
    return Text(
      year.toString(),
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildMonthSection(
    BuildContext context,
    int month,
    List<AtlasMemory> memories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 12,
          ),
          child: Text(
            _monthName(month),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),

        ...memories.map(
          (memory) {
            return _buildTimelineMemory(
              context,
              memory,
            );
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTimelineMemory(
    BuildContext context,
    AtlasMemory memory,
  ) {
    return InkWell(
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
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 16,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 58,
              child: Column(
                children: [
                  Text(
                    _dayName(memory.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    memory.date.day.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 2,
              height: 100,
              color: Colors.grey.shade300,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    _buildThumbnail(memory),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            memory.title,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          if (memory.location.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons
                                      .location_on_outlined,
                                  size: 14,
                                  color: Colors
                                      .grey.shade600,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    memory.location,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors
                                          .grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 6),

                          Text(
                            _photoCount(memory),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),

                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(AtlasMemory memory) {
    if (memory.photoPaths.isEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.photo_outlined,
          color: Colors.grey.shade500,
        ),
      );
    }

    // The timeline currently doesn't resolve local photo
    // paths because the MemoryDetailsScreen already handles
    // that logic. Use a simple placeholder for now.
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.photo,
        color: Colors.grey.shade500,
      ),
    );
  }

  String _photoCount(AtlasMemory memory) {
    final count = memory.photoPaths.length;

    if (count == 0) {
      return 'No photos';
    }

    if (count == 1) {
      return '1 photo';
    }

    return '$count photos';
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }

  String _dayName(DateTime date) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[date.weekday - 1];
  }
}