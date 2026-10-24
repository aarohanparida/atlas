import 'package:flutter/material.dart';

import '../models/shared_timeline.dart';
import '../services/shared_timeline_service.dart';
import 'shared_timeline_detail_screen.dart';

class SharedScreen extends StatefulWidget {
  const SharedScreen({super.key});

  @override
  State<SharedScreen> createState() => _SharedScreenState();
}

class _SharedScreenState extends State<SharedScreen> {
  final SharedTimelineService _service = SharedTimelineService();

  Future<void> _showNameDialog() async {
    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _TimelineNameDialog(),
    );

    if (!mounted || name == null || name.trim().isEmpty) {
      return;
    }

    try {
      await _service.createTimeline(name);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timeline created!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create timeline: $e'),
        ),
      );
    }
  }

  Future<void> _showJoinDialog() async {
    final code = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _JoinTimelineDialog(),
    );

    if (!mounted || code == null || code.trim().isEmpty) {
      return;
    }

    try {
      await _service.joinTimeline(code);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Joined timeline!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not join timeline: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Timelines'),
        actions: [
          IconButton(
            tooltip: 'Join timeline',
            onPressed: _showJoinDialog,
            icon: const Icon(Icons.group_add_outlined),
          ),
          IconButton(
            tooltip: 'Create timeline',
            onPressed: _showNameDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<SharedTimeline>>(
        stream: _service.getMyTimelines(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load shared timelines.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final timelines = snapshot.data ?? [];

          if (timelines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 58,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Make memories together',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a shared timeline or join one '
                      'with an invite code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _showNameDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Create timeline'),
                    ),
                    TextButton(
                      onPressed: _showJoinDialog,
                      child: const Text('Join with a code'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: timelines.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final timeline = timelines[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.people_outline,
                      color: colors.primary,
                    ),
                  ),
                  title: Text(
                    timeline.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${timeline.memberIds.length} '
                    '${timeline.memberIds.length == 1 ? 'member' : 'members'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SharedTimelineDetailScreen(
                          timeline: timeline,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// The dialog owns its controller and disposes it with its own lifecycle.
class _TimelineNameDialog extends StatefulWidget {
  const _TimelineNameDialog();

  @override
  State<_TimelineNameDialog> createState() =>
      _TimelineNameDialogState();
}

class _TimelineNameDialogState extends State<_TimelineNameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a timeline'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Timeline name',
          hintText: 'Family, Basketball, Friends...',
        ),
        onSubmitted: (_) {
          Navigator.of(context).pop(_controller.text.trim());
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text.trim());
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _JoinTimelineDialog extends StatefulWidget {
  const _JoinTimelineDialog();

  @override
  State<_JoinTimelineDialog> createState() =>
      _JoinTimelineDialogState();
}

class _JoinTimelineDialogState extends State<_JoinTimelineDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join a timeline'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'Invite code',
          hintText: 'Paste the code you received',
        ),
        onSubmitted: (_) {
          Navigator.of(context).pop(_controller.text.trim());
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text.trim());
          },
          child: const Text('Join'),
        ),
      ],
    );
  }
}