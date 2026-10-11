import 'package:flutter/material.dart';

import '../models/atlas_memory.dart';
import '../services/memory_service.dart';

class EditMemoryScreen extends StatefulWidget {
  final AtlasMemory memory;

  const EditMemoryScreen({
    super.key,
    required this.memory,
  });

  @override
  State<EditMemoryScreen> createState() =>
      _EditMemoryScreenState();
}

class _EditMemoryScreenState extends State<EditMemoryScreen> {
  final MemoryService _memoryService = MemoryService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _peopleController;

  late DateTime _selectedDate;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.memory.title);

    _descriptionController =
        TextEditingController(text: widget.memory.description);

    _locationController =
        TextEditingController(text: widget.memory.location);

    _peopleController = TextEditingController(
      text: widget.memory.people.join(', '),
    );

    _selectedDate = widget.memory.date;
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

  Future<void> _saveChanges() async {
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

      await _memoryService.updateMemory(
        memoryId: widget.memory.id,
        title: title,
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        location: _locationController.text.trim(),
        people: people,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not save changes. Please try again.';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Edit Memory'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: _inputDecoration('Title'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: _inputDecoration('Description'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _locationController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: _inputDecoration('Location'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _peopleController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: _inputDecoration(
                'People',
                hint: 'John, Sarah, Mike',
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: _chooseDate,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                    const SizedBox(width: 12),
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

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: colorScheme.error),
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveChanges,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    String? hint,
  }) {
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
