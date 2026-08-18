import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service to handle local scheduled reminders for milk entries.
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize local notifications and timezone DB
  Future<void> init() async {
    if (_initialized) return;

    // 1. Initialize timezone database
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Calcutta'));
      } catch (_) {}
    }

    // 2. Setup Android and iOS initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 3. Initialize plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Can handle app launch when notification is tapped
      },
    );

    _initialized = true;
  }

  /// Request permissions on Android 13+ and iOS
  Future<bool> requestPermissions() async {
    await init();
    if (Platform.isAndroid) {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return true;
  }

  /// Cancel all scheduled reminders
  /// तुरंत एक सूचना दिखाओ (कोई schedule नहीं) — जैसे "महीने का हिसाब तैयार है"।
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'report_ready_channel',
      'रिपोर्ट तैयार',
      channelDescription: 'महीना पूरा होने पर हिसाब की रिपोर्ट तैयार होने की सूचना।',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    try {
      await _notificationsPlugin.show(id, title, body, details);
    } catch (_) {}
  }

  Future<void> cancelAllReminders() async {
    await init();
    await _notificationsPlugin.cancel(101); // Morning reminder ID
    await _notificationsPlugin.cancel(102); // Evening reminder ID
  }

  // ── 🛡️ हफ़्ते में एक बार: "अपना हिसाब सुरक्षित कीजिए" ────────────────
  //
  // यह उन किसानों के लिए है जिनके फ़ोन में **Google खाता नहीं है**। उनका
  // Android auto-backup चलता ही नहीं — फ़ोन खोया या टूटा तो महीनों का हिसाब
  // हमेशा के लिए गया।
  //
  // गाँव में यह आम है। इसलिए हफ़्ते में एक बार याद दिलाते हैं कि backup
  // फ़ाइल ख़ुद को WhatsApp पर भेज दें — वह फ़ाइल फिर उनके अपने WhatsApp में
  // पड़ी रहती है, जो सबसे भरोसेमंद जगह है।
  //
  // जिनका Google खाता जुड़ा है उन्हें यह नहीं दिखता (देखें BackupReminder)।

  static const int _backupReminderId = 777;

  /// रविवार सुबह 10 बजे — जब किसान आम तौर पर फ़ुरसत में होता है
  Future<void> scheduleWeeklyBackupReminder({
    required String title,
    required String body,
  }) async {
    await init();
    await _notificationsPlugin.cancel(_backupReminderId);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'backup_reminder_channel',
        'हिसाब सुरक्षित रखने की याद',
        channelDescription:
            'हफ़्ते में एक बार याद दिलाता है कि अपना हिसाब backup कर लें, '
            'ताकि फ़ोन खोने पर भी कुछ न जाए।',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // अगला रविवार सुबह 10 बजे ढूँढ़ो
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    // DateTime.sunday == 7
    while (when.weekday != DateTime.sunday || !when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
      when = tz.TZDateTime(tz.local, when.year, when.month, when.day, 10);
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        _backupReminderId, title, body, when, details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // हर हफ़्ते उसी दिन-समय पर दोहराओ
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (_) {
      // कुछ फ़ोन exact alarm नहीं देते — तब भी चुपचाप चलता रहे
    }
  }

  /// Google खाता जुड़ जाए तो यह याद दिलाना बंद कर दो — उसका backup अपने आप
  /// होता रहता है, रोज़ टोकने का कोई मतलब नहीं।
  Future<void> cancelWeeklyBackupReminder() async {
    await init();
    await _notificationsPlugin.cancel(_backupReminderId);
  }

  /// Schedule daily notifications at specific times
  Future<void> scheduleDailyReminders({
    required bool morningEnabled,
    required String morningTime, // "HH:mm"
    required bool eveningEnabled,
    required String eveningTime, // "HH:mm"
  }) async {
    await init();
    await cancelAllReminders(); // Clear old scheduled reminders first

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'milk_entry_reminder_channel',
      'दूध एंट्री रिमाइंडर',
      channelDescription: 'दूध की सुबह और शाम की एंट्री दर्ज करने की याद दिलाता है।',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule Morning Reminder
    if (morningEnabled) {
      final morningParts = morningTime.split(':');
      final hour = int.tryParse(morningParts[0]) ?? 8;
      final minute = int.tryParse(morningParts[1]) ?? 30;

      await _scheduleDailyNotification(
        id: 101,
        title: '☀️ सुबह के दूध का हिसाब!',
        body: 'आज सुबह के दूध की एंट्री दर्ज करना न भूलें। ऐप खोलें और एंट्री करें।',
        hour: hour,
        minute: minute,
        notificationDetails: platformDetails,
      );
    }

    // Schedule Evening Reminder
    if (eveningEnabled) {
      final eveningParts = eveningTime.split(':');
      final hour = int.tryParse(eveningParts[0]) ?? 20;
      final minute = int.tryParse(eveningParts[1]) ?? 30;

      await _scheduleDailyNotification(
        id: 102,
        title: '🌙 शाम के दूध का हिसाब!',
        body: 'आज शाम के दूध की एंट्री दर्ज करना न भूलें। ऐप खोलें और हिसाब पूरा करें।',
        hour: hour,
        minute: minute,
        notificationDetails: platformDetails,
      );
    }
  }

  // ── पशु (ब्याने) रिमाइंडर ─────────────────────────────────────────────
  // ID range 500+ ताकि दूध वाले 101/102 से न टकराए। हर पशु का id ही
  // notification id बन जाता है (500 + pashuId)।
  static const int _pashuIdBase = 500;

  /// एक पशु के ब्याने से 7 दिन पहले और उसी दिन याद दिलाओ।
  Future<void> schedulePashuCalvingReminder({
    required int pashuId,
    required String pashuName,
    required DateTime calvingDate,
  }) async {
    await init();
    await cancelPashuReminder(pashuId);

    const androidDetails = AndroidNotificationDetails(
      'pashu_reminder_channel',
      'पशु रिमाइंडर',
      channelDescription: 'पशु के ब्याने और टीके की याद दिलाता है।',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // सुबह 8 बजे — किसान उस समय जाग चुका होता है
    final warnAt = calvingDate.subtract(const Duration(days: 7));
    await _scheduleOnce(
      id: _pashuIdBase + pashuId * 2,
      title: '🐄 $pashuName — ब्याने में 7 दिन',
      body: 'तैयारी कर लें: साफ़ जगह, हरा चारा और पशु चिकित्सक का नंबर पास रखें।',
      when: DateTime(warnAt.year, warnAt.month, warnAt.day, 8),
      details: details,
    );
    await _scheduleOnce(
      id: _pashuIdBase + pashuId * 2 + 1,
      title: '🐄 $pashuName — आज ब्याने की संभावित तारीख़',
      body: 'पशु पर नज़र रखें। कोई दिक़्क़त लगे तो तुरंत पशु चिकित्सक को बुलाएँ।',
      when: DateTime(calvingDate.year, calvingDate.month, calvingDate.day, 8),
      details: details,
    );
  }

  /// 💉 पालन (बकरी/मुर्गी आदि) के टीकों के रिमाइंडर।
  ///
  /// [startDate] = बच्चे आने/जन्म की तारीख़; हर टीका उसके कितने दिन बाद है,
  /// वह [plan] में आता है। एक ही पालन के पुराने रिमाइंडर पहले हटा दिए जाते
  /// हैं ताकि दो बार लगाने पर दुगने notification न आएँ।
  static const int _palanIdBase = 2000;

  Future<int> schedulePalanVaccines({
    required int slot, // 0..19 — हर पालन का अपना खाना
    required String palanName,
    required DateTime startDate,
    required List<({int day, String what})> plan,
  }) async {
    await init();
    await cancelPalanVaccines(slot);

    const androidDetails = AndroidNotificationDetails(
      'palan_vaccine_channel',
      'टीका रिमाइंडर',
      channelDescription: 'बकरी/मुर्गी आदि के टीके की याद दिलाता है।',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    var scheduled = 0;
    for (var i = 0; i < plan.length && i < 20; i++) {
      final item = plan[i];
      final when = startDate.add(Duration(days: item.day));
      if (when.isBefore(DateTime.now())) continue; // बीत चुका
      await _scheduleOnce(
        id: _palanIdBase + slot * 20 + i,
        title: '💉 $palanName — आज टीका लगवाएँ',
        body: item.what,
        when: DateTime(when.year, when.month, when.day, 8),
        details: details,
      );
      scheduled++;
    }
    return scheduled;
  }

  Future<void> cancelPalanVaccines(int slot) async {
    await init();
    for (var i = 0; i < 20; i++) {
      try {
        await _notificationsPlugin.cancel(_palanIdBase + slot * 20 + i);
      } catch (_) {}
    }
  }

  /// ⚠️ `cancel` भी फेंक सकता है — इसे कभी ऊपर तक न जाने दें।
  ///
  /// plugin हर cancel पर अपना रखा हुआ cache पढ़ता है। 9 अगस्त 2026 को असली
  /// फ़ोन पर वही `Missing type parameter.` फेंक रहा था और पशु सेव करने वाली
  /// screen वहीं जाम हो जाती थी। जड़ `proguard-rules.pro` में ठीक की गई है;
  /// यहाँ की पकड़ इसलिए है कि पुराना रिमाइंडर न हटे तो भी नया लगना रुके नहीं।
  Future<void> cancelPashuReminder(int pashuId) async {
    await init();
    for (final id in [_pashuIdBase + pashuId * 2, _pashuIdBase + pashuId * 2 + 1]) {
      try {
        await _notificationsPlugin.cancel(id);
      } catch (e) {
        debugPrint('पुराना पशु रिमाइंडर ($id) नहीं हटा: $e');
      }
    }
  }

  /// एक बार बजने वाला notification (बीती तारीख़ चुपचाप छोड़ दी जाती है)।
  Future<void> _scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required NotificationDetails details,
  }) async {
    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;

    try {
      await _notificationsPlugin.zonedSchedule(
        id, title, body, scheduled, details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      await _notificationsPlugin.zonedSchedule(
        id, title, body, scheduled, details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Helper to schedule a daily recurring notification at a specific hour/minute
  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationDetails notificationDetails,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has already passed today, schedule it for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Fallback to inexact mode if exact alarm permission is not granted on Android 12+/14+
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}
