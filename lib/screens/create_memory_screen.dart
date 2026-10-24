import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import '../services/memory_service.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class CreateMemoryScreen extends StatefulWidget {
  const CreateMemoryScreen({
    super.key,
    this.discoveredAssets = const [],
  });

  final List<AssetEntity> discoveredAssets;

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
  void initState() {
    super.initState();

    if (widget.discoveredAssets.isNotEmpty) {
      _selectedDate =
          widget.discoveredAssets.first.createDateTime;
    }
  }

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

    if (selectedDate != null && mounted) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _pickPhotos() async {
    try {
      final images = await _picker.pickMultiImage();

      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedImages = [
            ..._selectedImages,
            ...images,
          ];
          _error = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not select photos. Please try again.';
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

    final savedPaths = <String>[];

    Future<void> copyPhoto(File source) async {
      final extension = path.extension(source.path);
      final timestamp =
          DateTime.now().microsecondsSinceEpoch;

      final fileName = '${timestamp}_${savedPaths.length}'
          '${extension.isEmpty ? '.jpg' : extension}';

      final destination = File(
        '${photosDirectory.path}/$fileName',
      );

      await source.copy(destination.path);
      savedPaths.add('memory_photos/$fileName');
    }

    // Copy photos selected from the device photo library.
    for (final asset in widget.discoveredAssets) {
      final file = await asset.file;

      if (file != null && await file.exists()) {
        await copyPhoto(file);
      }
    }

    // Copy photos selected through the regular image picker.
    for (final image in _selectedImages) {
      final file = File(image.path);

      if (await file.exists()) {
        await copyPhoto(file);
      }
    }

    return savedPaths;
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
      debugPrint('Could not save memory: $e');

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final discoveredPhotos = widget.discoveredAssets;

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
                textCapitalization:
                    TextCapitalization.sentences,
                style: TextStyle(color: colors.onSurface),
                decoration: _inputDecoration(
                  'Title',
                  'Rhode Island Trip',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                textCapitalization:
                    TextCapitalization.sentences,
                maxLines: 4,
                style: TextStyle(color: colors.onSurface),
                decoration: _inputDecoration(
                  'Description',
                  'What made this memory special?',
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _saving ? null : _chooseDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: colors.onSurface,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _formattedDate(),
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: colors.onSurface),
                decoration: _inputDecoration(
                  'Location',
                  'Newport, Rhode Island',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _peopleController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: colors.onSurface),
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
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickPhotos,
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: Text(
                  _photoCount == 0
                      ? 'Add Photos'
                      : '$_photoCount Photos Selected',
                ),
              ),
              if (_photoCount > 0) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photoCount,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final isDiscovered =
                          index < discoveredPhotos.length;

                      final Widget photo = isDiscovered
                          ? AssetEntityImage(
                              discoveredPhotos[index],
                              isOriginal: false,
                              thumbnailSize:
                                  const ThumbnailSize.square(250),
                              fit: BoxFit.cover,
                              width: 110,
                              height: 110,
                            )
                          : Image.file(
                              File(
                                _selectedImages[
                                  index - discoveredPhotos.length
                                ].path,
                              ),
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            );

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: photo,
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
                  style: TextStyle(color: colors.error),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveMemory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
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

  int get _photoCount =>
      widget.discoveredAssets.length + _selectedImages.length;

  InputDecoration _inputDecoration(
    String label,
    String hint,
  ) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: colors.onSurfaceVariant,
      ),
      hintStyle: TextStyle(
        color: colors.onSurfaceVariant,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}
