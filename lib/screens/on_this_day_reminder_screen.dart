import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class OnThisDayReminderScreen extends StatefulWidget {
  const OnThisDayReminderScreen({super.key});

  @override
  State<OnThisDayReminderScreen> createState() =>
      _OnThisDayReminderScreenState();
}

class _OnThisDayReminderScreenState
    extends State<OnThisDayReminderScreen> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final enabled = await NotificationService.instance
          .isOnThisDayReminderEnabled();

      if (!mounted) return;

      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      _loading = true;
    });

    try {
      if (value) {
        final enabled = await NotificationService.instance
            .enableOnThisDayReminder();

        if (!mounted) return;

        setState(() {
          _enabled = enabled;
          _loading = false;
        });

        if (!enabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notifications are not allowed. Enable them '
                'in your iPhone Settings to use reminders.',
              ),
            ),
          );
        }
      } else {
        await NotificationService.instance
            .disableOnThisDayReminder();

        if (!mounted) return;

        setState(() {
          _enabled = false;
          _loading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update reminder: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reminders'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: _enabled,
            onChanged: _loading ? null : _toggleReminder,
            title: const Text('On This Day'),
            subtitle: const Text(
              'Get a daily reminder at 6:00 PM to revisit '
              'your memories in Atlas.',
            ),
            secondary: const Icon(Icons.history),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Reminders are delivered by your device. '
              'You can turn them off at any time.',
            ),
          ),
        ],
      ),
    );
  }
}