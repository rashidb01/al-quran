import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../l10n.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<void> init() async {
    if (!_supported || _initialized) return;
    tz_data.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      ),
      macOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> requestPermission() async {
    if (!_supported) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await macos?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> scheduleReminders({
    required int totalCount,
    required int currentCounter,
    required int divider,
    required AppLocale locale,
  }) async {
    if (!_supported || divider <= 0) return;

    await _plugin.cancelAll();

    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 22, 0);
    if (now.isAfter(end)) return;

    final startHour = now.hour < 4 ? 4 : now.hour + 1;
    final times = <DateTime>[];
    for (int h = startHour; h <= 22; h++) {
      final t = DateTime(now.year, now.month, now.day, h, 0);
      if (t.isAfter(end)) break;
      times.add(t);
    }
    if (times.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notif_times',
      times.map((t) => t.millisecondsSinceEpoch.toString()).join(','),
    );

    final l = L10n(locale);
    final remaining = totalCount - currentCounter;
    for (int i = 0; i < times.length; i++) {
      final nextTime = i + 1 < times.length ? _fmt(times[i + 1]) : null;
      await _scheduleOne(i, times[i], l.notifTitle, l.notifBody(
        remaining: remaining,
        total: totalCount,
        perStep: divider,
        nextTime: nextTime,
      ));
    }
  }

  static Future<void> rescheduleWithNewRemaining({
    required int totalCount,
    required int currentCounter,
    required AppLocale locale,
  }) async {
    if (!_supported) return;
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('notif_times');
    if (str == null || str.isEmpty) return;

    final now = DateTime.now();
    final future = str
        .split(',')
        .map((s) => DateTime.fromMillisecondsSinceEpoch(int.parse(s)))
        .where((t) => t.isAfter(now))
        .toList();
    if (future.isEmpty) return;

    final remaining = totalCount - currentCounter;
    if (remaining <= 0) {
      await _plugin.cancelAll();
      await prefs.remove('notif_times');
      return;
    }

    await _plugin.cancelAll();
    final prefs2 = await SharedPreferences.getInstance();
    final savedDivider = prefs2.getInt('dividerCount') ?? 1;
    final l = L10n(locale);
    for (int i = 0; i < future.length; i++) {
      final nextTime = i + 1 < future.length ? _fmt(future[i + 1]) : null;
      await _scheduleOne(i, future[i], l.notifTitle, l.notifBody(
        remaining: remaining,
        total: totalCount,
        perStep: savedDivider,
        nextTime: nextTime,
      ));
    }
  }

  static Future<void> cancelAll() async {
    if (!_supported) return;
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notif_times');
  }

  static String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static tz.TZDateTime _toTZ(DateTime local) {
    final u = local.toUtc();
    return tz.TZDateTime.utc(u.year, u.month, u.day, u.hour, u.minute, u.second);
  }

  static Future<void> _scheduleOne(
      int id, DateTime time, String title, String body) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _toTZ(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sanaq_reminders',
          'Sanaq Reminders',
          channelDescription: 'Quran reading reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
