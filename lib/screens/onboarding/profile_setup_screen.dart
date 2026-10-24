import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../services/user_service.dart';
import '../permissions/photos_permission_screen.dart';

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

    if (selectedDate != null && mounted) {
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = colors.onSurface;
    final secondaryTextColor = colors.onSurfaceVariant;
    final fieldColor = colors.surfaceContainerHighest;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              Text(
                'Make Atlas yours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Tell us a little about you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: textColor),
                cursorColor: colors.primary,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(
                    color: secondaryTextColor,
                  ),
                  filled: true,
                  fillColor: fieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colors.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: _loading ? null : _chooseBirthday,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: textColor,
                  side: BorderSide(
                    color: colors.outlineVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
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
                  style: TextStyle(
                    color: colors.error,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _loading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
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
