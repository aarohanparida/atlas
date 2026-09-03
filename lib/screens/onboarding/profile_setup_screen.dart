import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import '../permissions/photos_permission_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController =
      TextEditingController();

  final UserService _userService = UserService();

  DateTime? _birthday;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _chooseBirthday() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 15),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selectedDate != null) {
      setState(() {
        _birthday = selectedDate;
      });
    }
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _error = 'Please enter your full name.';
      });

      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _userService.createProfile(
        name: name,
        birthday: _birthday,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PhotosPermissionScreen(),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = '${e.code}: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              const Text(
                'Make Atlas yours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Tell us a little about you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: _chooseBirthday,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(
                  _birthday == null
                      ? 'Birthday (optional)'
                      : '${_birthday!.month}/${_birthday!.day}/${_birthday!.year}',
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 15),

                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _continue,

                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Continue'),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}