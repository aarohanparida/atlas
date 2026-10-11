import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/atlas_memory.dart';
import '../services/memory_service.dart';
import 'edit_memory_screen.dart';

class MemoryDetailsScreen extends StatefulWidget {
  final AtlasMemory memory;

  const MemoryDetailsScreen({
    super.key,
    required this.memory,
  });

  @override
  State<MemoryDetailsScreen> createState() =>
      _MemoryDetailsScreenState();
}

class _MemoryDetailsScreenState
    extends State<MemoryDetailsScreen> {
  final MemoryService _memoryService = MemoryService();

  late AtlasMemory _memory;
  late PageController _pageController;

  List<String> _resolvedPhotoPaths = [];

  int _currentPage = 0;
  int _lastHapticLevel = -1;

  @override
  void initState() {
    super.initState();

    _memory = widget.memory;
    _pageController = PageController();

    _loadPhotoPaths();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotoPaths() async {
    final paths = <String>[];

    for (final storedPath in _memory.photoPaths) {
      final resolvedPath = await _resolvePhotoPath(storedPath);
      paths.add(resolvedPath);
    }

    if (!mounted) return;

    setState(() {
      _resolvedPhotoPaths = paths;
    });

    for (final photoPath in paths) {
      if (!mounted) return;

      await precacheImage(
        FileImage(File(photoPath)),
        context,
      );
    }
  }

  Future<String> _resolvePhotoPath(String storedPath) async {
    final directory = await getApplicationDocumentsDirectory();

    if (!storedPath.startsWith('/')) {
      return '${directory.path}/$storedPath';
    }

    if (await File(storedPath).exists()) {
      return storedPath;
    }

    final fileName = storedPath.split('/').last;

    return '${directory.path}/memory_photos/$fileName';
  }

  String _formatDate(DateTime date) {
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

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }

  void _handlePhotoScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _lastHapticLevel = -1;
      return;
    }

    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;

      if (metrics.viewportDimension <= 0) return;

      final page = metrics.pixels / metrics.viewportDimension;
      final nearestPage = page.round();
      final distance = (page - nearestPage).abs();

      if (distance < 0.02) return;

      final progress = distance.clamp(0.0, 0.5) / 0.5;

      int level;

      if (progress < 0.33) {
        level = 0;
      } else if (progress < 0.66) {
        level = 1;
      } else {
        level = 2;
      }

      if (level != _lastHapticLevel) {
        _lastHapticLevel = level;

        if (level == 0) {
          HapticFeedback.lightImpact();
        } else if (level == 1) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.heavyImpact();
        }
      }
    }

    if (notification is ScrollEndNotification) {
      _lastHapticLevel = -1;
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _editMemory() async {
    final edited = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditMemoryScreen(
          memory: _memory,
        ),
      ),
    );

    if (edited == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteMemory() async {
    final colorScheme = Theme.of(context).colorScheme;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Memory?'),
          content: const Text(
            'This will permanently delete this memory '
            'and its photos from this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _memoryService.deleteMemory(_memory.id);

      for (final photoPath in _resolvedPhotoPaths) {
        final file = File(photoPath);

        if (await file.exists()) {
          await file.delete();
        }
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete this memory.'),
        ),
      );
    }
  }

  Widget _buildPhoto(
    String photoPath,
    ColorScheme colorScheme,
  ) {
    return Image.file(
      File(photoPath),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: colorScheme.surfaceContainerHighest,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Photo could not be loaded',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotos(ColorScheme colorScheme) {
    if (_memory.photoPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_resolvedPhotoPaths.length != _memory.photoPaths.length) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _handlePhotoScroll(notification);
        return false;
      },
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _resolvedPhotoPaths.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildPhoto(
                      _resolvedPhotoPaths[index],
                      colorScheme,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_resolvedPhotoPaths.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _resolvedPhotoPaths.length,
                (index) {
                  final selected = index == _currentPage;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: selected ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Memory'),
        actions: [
          IconButton(
            tooltip: 'Edit memory',
            onPressed: _editMemory,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete memory',
            onPressed: _deleteMemory,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _memory.title,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _formatDate(_memory.date),
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            if (_memory.location.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _memory.location,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            _buildPhotos(colorScheme),

            if (_memory.photoPaths.isNotEmpty)
              const SizedBox(height: 24),

            if (_memory.description.isNotEmpty) ...[
              Text(
                _memory.description,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (_memory.people.isNotEmpty) ...[
              Text(
                'People',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _memory.people.map((person) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      person,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _editMemory,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Memory'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(
                    color: colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _deleteMemory,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Memory'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(
                    color: colorScheme.error,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}