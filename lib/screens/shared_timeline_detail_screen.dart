import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/atlas_memory.dart';
import '../models/shared_timeline.dart';
import '../services/memory_service.dart';
import '../services/shared_timeline_service.dart';

class SharedTimelineDetailScreen extends StatefulWidget {
  final SharedTimeline timeline;

  const SharedTimelineDetailScreen({
    super.key,
    required this.timeline,
  });

  @override
  State<SharedTimelineDetailScreen> createState() =>
      _SharedTimelineDetailScreenState();
}

class _SharedTimelineDetailScreenState
    extends State<SharedTimelineDetailScreen> {
  final SharedTimelineService _sharedService =
      SharedTimelineService();

  final MemoryService _memoryService = MemoryService();

  bool _sharing = false;

  Future<void> _shareMemory(
    AtlasMemory memory,
    BuildContext dialogContext,
  ) async {
    if (_sharing) return;

    setState(() {
      _sharing = true;
    });

    try {
      await _sharedService.shareMemory(
        widget.timeline,
        memory,
      );

      if (!mounted) return;

      // Close only the memory-selection dialog.
      Navigator.pop(dialogContext);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memory shared!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not share memory: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
        });
      }
    }
  }

  void _chooseMemory() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Share a memory'),
          content: SizedBox(
            width: 400,
            height: 350,
            child: StreamBuilder<List<AtlasMemory>>(
              stream: _memoryService.getAllMemories(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Could not load your memories.',
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final memories = snapshot.data ?? [];

                if (memories.isEmpty) {
                  return const Center(
                    child: Text(
                      'Create a personal memory first.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    final memory = memories[index];

                    return ListTile(
                      title: Text(memory.title),
                      subtitle: Text(
                        '${memory.date.month}/'
                        '${memory.date.day}/'
                        '${memory.date.year}'
                        '${memory.location.isNotEmpty ? ' • ${memory.location}' : ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: _sharing
                          ? null
                          : () => _shareMemory(
                                memory,
                                dialogContext,
                              ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: _sharing
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyInviteCode() async {
    await Clipboard.setData(
      ClipboardData(
        text: widget.timeline.inviteCode,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite code copied'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeline = widget.timeline;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(timeline.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sharing ? null : _chooseMemory,
        icon: const Icon(Icons.add),
        label: const Text('Share memory'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.key_outlined,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Invite code',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          timeline.inviteCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy invite code',
                    onPressed: _copyInviteCode,
                    icon: const Icon(Icons.copy),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AtlasMemory>>(
              stream: _sharedService.getTimelineMemories(
                timeline.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Could not load shared memories.',
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final memories = snapshot.data ?? [];

                if (memories.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Text(
                        'No memories here yet.\n'
                        'Share one of your memories to get started.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    100,
                  ),
                  itemCount: memories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final memory = memories[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.photo_album_outlined,
                        ),
                        title: Text(memory.title),
                        subtitle: Text(
                          '${memory.date.month}/'
                          '${memory.date.day}/'
                          '${memory.date.year}'
                          '${memory.location.isNotEmpty ? ' • ${memory.location}' : ''}',
                        ),
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (detailContext) {
                              return AlertDialog(
                                title: Text(memory.title),
                                content: SingleChildScrollView(
                                  child: Text(
                                    [
                                      '${memory.date.month}/'
                                          '${memory.date.day}/'
                                          '${memory.date.year}',
                                      if (memory.location.isNotEmpty)
                                        'Location: ${memory.location}',
                                      if (memory.description.isNotEmpty)
                                        memory.description,
                                      if (memory.people.isNotEmpty)
                                        'People: ${memory.people.join(', ')}',
                                    ].join('\n\n'),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(detailContext),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}