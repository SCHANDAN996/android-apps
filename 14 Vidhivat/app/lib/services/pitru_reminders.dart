import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../state/ancestor_profiles.dart';
import '../state/settings.dart';

class PitruReminders {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _init() async {
    if (_ready || !supported) return;
    tz.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// केवल यूज़र के switch दबाने पर सिस्टम अनुमति माँगें।
  Future<bool> askPermission() async {
    if (!supported) return false;
    await _init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: false, sound: true) ??
        false;
  }

  int _notificationId(String id) {
    var hash = 0;
    for (final char in id.codeUnits) {
      hash = (hash * 31 + char) & 0x7fffffff;
    }
    return hash;
  }

  Future<void> cancel(String id) async {
    if (!supported) return;
    await _init();
    await _plugin.cancel(id: _notificationId(id));
  }

  /// अगला एक स्मरण-दिन schedule होता है; ऐप अगली बार खुलने पर नया साल
  /// फिर निकालेगा। Exact alarm नहीं लिया जाता, इसलिए समय लगभग है।
  Future<void> schedule(AncestorProfile profile) async {
    if (!supported) return;
    await _init();
    await cancel(profile.id);
    if (!profile.reminder) return;
    final now = DateTime.now();
    var next = profile.nextDay(now, observingPlace: settings.place);
    if (next == null) return;
    DateTime atUtc(DateTime day) =>
        DateTime.utc(day.year, day.month, day.day, 9)
            .subtract(settings.place.timeZoneOffset);
    if (!atUtc(next.date).isAfter(now.toUtc())) {
      next = profile.nextDay(now.add(const Duration(days: 1)),
          observingPlace: settings.place);
    }
    if (next == null) return;
    final body = profile.showNameOnLockScreen && profile.name.isNotEmpty
        ? 'आज ${profile.name} का स्मरण-दिन है'
        : 'आज परिवार का स्मरण-दिन है';
    await _plugin.zonedSchedule(
      id: _notificationId(profile.id),
      title: 'पितृ-स्मरण',
      body: body,
      scheduledDate: tz.TZDateTime.from(atUtc(next.date), tz.UTC),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'pitru_smaran',
          'पितृ-स्मरण',
          channelDescription: 'परिवार की चुनी हुई तिथि का स्थानीय स्मरण',
          visibility: profile.showNameOnLockScreen
              ? NotificationVisibility.public
              : NotificationVisibility.private,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> refresh() async {
    if (!supported) return;
    for (final profile in ancestorProfiles.items.where((p) => p.reminder)) {
      try {
        await schedule(profile);
      } catch (_) {
        // ऐप खुलना कभी reminder provider की वजह से नहीं रुकेगा।
      }
    }
  }
}

final pitruReminders = PitruReminders();
