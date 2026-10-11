import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final dynamic currentBirthday;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentBirthday,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;

  final UserService _userService = UserService();

  DateTime? _birthday;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.currentName,
    );

    if (widget.currentBirthday is Timestamp) {
      _birthday =
          (widget.currentBirthday as Timestamp).toDate();
    } else if (widget.currentBirthday is DateTime) {
      _birthday = widget.currentBirthday as DateTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _chooseBirthday() async {
    final now = DateTime.now();
    final initialDate = _birthday ?? DateTime(now.year - 15);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _birthday = selectedDate;
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _error = 'Please enter your name.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _userService.updateProfile(
        name: name,
        birthday: _birthday,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Could not update your profile. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _birthdayText() {
    if (_birthday == null) {
      return 'Birthday (optional)';
    }

    return '${_birthday!.month}/${_birthday!.day}/${_birthday!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  labelStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: _loading ? null : _chooseBirthday,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(_birthdayText()),
              ),

              if (_birthday != null)
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _birthday = null;
                          });
                        },
                  child: const Text('Remove birthday'),
                ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.error,
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}