import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/atlas_memory.dart';
import 'memory_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  // Keep the legacy ID so the old generic reminder can be removed.
  static const int onThisDayNotificationId = 1001;

  // IDs for smart reminders are dates in YYYYMMDD format.
  static const int _smartIdStart = 20000000;
  static const int _smartIdEnd = 29999999;
  static const int _maxScheduledReminders = 60;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _userDocument {
    final uid = _uid;
    if (uid == null) {
      throw Exception('No signed-in user.');
    }

    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const settings = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: settings);
    _initialized = true;

    print('🔔 Notifications initialized in ${tz.local.name}');
  }

  Future<bool> requestPermission() async {
    await initialize();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final granted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 Notification permission: $granted');
    return granted ?? false;
  }

  Future<bool> isOnThisDayReminderEnabled() async {
    await initialize();

    if (_uid == null) return false;

    try {
      final snapshot = await _userDocument.get();
      return snapshot.data()?['onThisDayReminderEnabled'] == true;
    } catch (error) {
      print('Could not load reminder preference: $error');
      return false;
    }
  }

  Future<bool> enableOnThisDayReminder() async {
    await initialize();

    final permissionGranted = await requestPermission();
    if (!permissionGranted) {
      print('❌ Notification permission denied.');
      return false;
    }

    if (_uid == null) {
      print('❌ Cannot enable reminders without a signed-in user.');
      return false;
    }

    // Save the user's preference without overwriting other profile fields.
    await _userDocument.set(
      {'onThisDayReminderEnabled': true},
      SetOptions(merge: true),
    );

    await refreshSmartOnThisDayReminders();
    return true;
  }

  Future<void> disableOnThisDayReminder() async {
    await initialize();

    if (_uid != null) {
      await _userDocument.set(
        {'onThisDayReminderEnabled': false},
        SetOptions(merge: true),
      );
    }

    await _cancelSmartNotifications();
    await _plugin.cancel(id: onThisDayNotificationId);

    print('🔔 On This Day reminders disabled.');
  }

  /// Refresh this after memories change and when the signed-in app opens.
  Future<void> refreshSmartOnThisDayReminders() async {
    await initialize();

    if (_uid == null) return;

    final enabled = await isOnThisDayReminderEnabled();
    if (!enabled) {
      await _cancelSmartNotifications();
      await _plugin.cancel(id: onThisDayNotificationId);
      return;
    }

    // Fetch the current user's memories from Firestore.
    final memories = await MemoryService().getAllMemories().first;

    // Remove outdated schedules before rebuilding them.
    await _cancelSmartNotifications();
    await _plugin.cancel(id: onThisDayNotificationId);

    final now = tz.TZDateTime.now(tz.local);
    final todayAtSix = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18,
    );

    // If today's reminder time has passed, start tomorrow.
    final firstDay = todayAtSix.isAfter(now)
        ? tz.TZDateTime(tz.local, now.year, now.month, now.day)
        : tz.TZDateTime(tz.local, now.year, now.month, now.day + 1);

    int scheduledCount = 0;

    // Look through the next 365 calendar days.
    for (int offset = 0; offset < 365; offset++) {
      if (scheduledCount >= _maxScheduledReminders) break;

      final day = tz.TZDateTime(
        tz.local,
        firstDay.year,
        firstDay.month,
        firstDay.day + offset,
      );

      final matchingMemories = memories.where((memory) {
        return memory.date.month == day.month &&
            memory.date.day == day.day &&
            memory.date.year < day.year;
      }).toList();

      if (matchingMemories.isEmpty) continue;

      // If multiple memories match, use the most recent past memory.
      matchingMemories.sort(
        (a, b) => b.date.compareTo(a.date),
      );

      final AtlasMemory memory = matchingMemories.first;

      final scheduledTime = tz.TZDateTime(
        tz.local,
        day.year,
        day.month,
        day.day,
        18,
      );

      final notificationId =
          day.year * 10000 + day.month * 100 + day.day;

      await _plugin.zonedSchedule(
        id: notificationId,
        title: 'On This Day: ${memory.title}',
        body: 'Take a moment to revisit this memory in Atlas.',
        scheduledDate: scheduledTime,
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      scheduledCount++;
      print('🔔 Scheduled "${memory.title}" for $scheduledTime');
    }

    print('🔔 Smart reminders scheduled: $scheduledCount');
  }

  Future<void> _cancelSmartNotifications() async {
    final pending = await _plugin.pendingNotificationRequests();

    for (final notification in pending) {
      if (notification.id >= _smartIdStart &&
          notification.id <= _smartIdEnd) {
        await _plugin.cancel(id: notification.id);
      }
    }
  }
}