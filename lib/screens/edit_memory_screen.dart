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

    if (selectedDate != null) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Edit Memory'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _peopleController,
              decoration: const InputDecoration(
                labelText: 'People',
                hintText: 'John, Sarah, Mike',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: _chooseDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 12),
                    Text(
                      _formattedDate(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
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
}