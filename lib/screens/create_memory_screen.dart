import 'package:flutter/material.dart';

import '../services/memory_service.dart';

class CreateMemoryScreen extends StatefulWidget {
  const CreateMemoryScreen({super.key});

  @override
  State<CreateMemoryScreen> createState() =>
      _CreateMemoryScreenState();
}

class _CreateMemoryScreenState
    extends State<CreateMemoryScreen> {
  final MemoryService _memoryService = MemoryService();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _locationController =
      TextEditingController();

  final TextEditingController _peopleController =
      TextEditingController();

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

      await _memoryService.createMemory(
        title: title,
        description:
            _descriptionController.text.trim(),
        date: _selectedDate,
        location:
            _locationController.text.trim(),
        people: people,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Could not save this memory. Please try again.';
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
        title: const Text(
          'New Memory',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                textCapitalization:
                    TextCapitalization.sentences,
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
                decoration: _inputDecoration(
                  'Description',
                  'What made this memory special?',
                ),
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _chooseDate,
                borderRadius:
                    BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          _formattedDate(),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _locationController,
                textCapitalization:
                    TextCapitalization.words,
                decoration: _inputDecoration(
                  'Location',
                  'Newport, Rhode Island',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _peopleController,
                textCapitalization:
                    TextCapitalization.words,
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
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: const Text(
                  'Add Photos — Coming Next',
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 20),

                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _saving ? null : _saveMemory,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Memory',
                        ),
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
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}