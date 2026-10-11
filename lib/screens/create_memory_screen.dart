import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../services/memory_service.dart';

class CreateMemoryScreen extends StatefulWidget {
  const CreateMemoryScreen({super.key});

  @override
  State<CreateMemoryScreen> createState() =>
      _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends State<CreateMemoryScreen> {
  final MemoryService _memoryService = MemoryService();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _locationController =
      TextEditingController();

  final TextEditingController _peopleController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  List<XFile> _selectedImages = [];

  DateTime _selectedDate = DateTime.now();

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _saveMemory() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _error = 'Give your memory a title.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final people = _peopleController.text
          .split(',')
          .map((person) => person.trim())
          .where((person) => person.isNotEmpty)
          .toList();

      final photoPaths = await _savePhotosLocally();

      await _memoryService.createMemory(
        title: title,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        location: _locationController.text.trim(),
        people: people,
        photoPaths: photoPaths,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not save this memory. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _formattedDate() {
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

    return '${months[_selectedDate.month - 1]} '
        '${_selectedDate.day}, '
        '${_selectedDate.year}';
  }

  Future<void> _pickPhotos() async {
    final images = await _picker.pickMultiImage();

    if (images.isNotEmpty && mounted) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  Future<List<String>> _savePhotosLocally() async {
    final directory = await getApplicationDocumentsDirectory();

    final photosDirectory = Directory(
      '${directory.path}/memory_photos',
    );

    if (!await photosDirectory.exists()) {
      await photosDirectory.create(recursive: true);
    }

    final List<String> savedPaths = [];

    for (final image in _selectedImages) {
      final extension = path.extension(image.path);

      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}$extension';

      final newPath =
          '${photosDirectory.path}/$fileName';

      await File(image.path).copy(newPath);

      savedPaths.add('memory_photos/$fileName');
    }

    return savedPaths;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('New Memory'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
                decoration: _inputDecoration(
                  'Title',
                  'Rhode Island Trip',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
                decoration: _inputDecoration(
                  'Description',
                  'What made this memory special?',
                ),
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _chooseDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: colorScheme.onSurface,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          _formattedDate(),
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),

                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
                decoration: _inputDecoration(
                  'Location',
                  'Newport, Rhode Island',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _peopleController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
                decoration: _inputDecoration(
                  'People',
                  'David, Sarah, Alex',
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Separate people with commas.',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: _saving ? null : _pickPhotos,
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: Text(
                  _selectedImages.isEmpty
                      ? 'Add Photos'
                      : '${_selectedImages.length} Photos Selected',
                ),
              ),

              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 16),

                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final image = _selectedImages[index];

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(image.path),
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: colorScheme.onPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 20),

                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.error,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveMemory,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Memory'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    String hint,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
      ),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}
