import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'bible_service.dart';
import 'package:flutter/material.dart';
import 'verse_screen.dart';
import 'main.dart';
import 'settings_service.dart';
import 'prayer_service.dart';
import 'prayer_detail_screen.dart';
import 'app_state_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

  static String? pendingPayload;
  /// Initialize
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await notifications.initialize(
      settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          final payload = response.payload;

          if (payload == null) return;

          final parts = payload.split("|");

          if (parts[0] == "verse") {
            final book = parts[1];
            final chapter = int.parse(parts[2]);
            final verse = int.parse(parts[3]);

            final bible = await AppStateService.getBible();

            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => VerseScreen(
                  book: book,
                  chapter: chapter,
                  targetVerse: verse,
                  initialVersion: bible["version"],
                ),
              ),
            );
          }

          else if (parts[0] == "prayer") {
            final title = parts[1];
            final content = parts.sublist(2).join("|");

            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => PrayerDetailScreen(
                  title: title,
                  content: content,
                ),
              ),
            );
          }
        },);
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Lagos'));

// Check if the app was opened from a notification
    final details =
    await notifications.getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp ?? false) {
      pendingPayload = details?.notificationResponse?.payload;
    }

    await loadAndScheduleAll();
  }

  static Future<void> loadAndScheduleAll() async {
    await notifications.cancelAll();

    final verseEnabled = await SettingsService.getVerseEnabled();
    final prayerEnabled = await SettingsService.getPrayerEnabled();

    if (verseEnabled) await scheduleDailyVerse();
    if (prayerEnabled) {
      await scheduleMorningPrayer();
      await scheduleEveningPrayer();
    }
  }

  // DAILY VERSE
  static Future<void> scheduleDailyVerse() async {
    final timeList = await SettingsService.getVerseTime();
    final hour = timeList[0];
    final minute = timeList[1];

    try {
      final version = await SettingsService.getBibleVersion();

      // Load today's theme from daily_verses.json
      final daily = await BibleService.getTodaysVerses(version);

      // Use the FIRST verse as today's notification
      final verse =
          (daily["verses"] as List<Map<String, dynamic>>).first;

      await notifications.zonedSchedule(
        11,
        '📖 ${verse['book']} ${verse['chapter']}:${verse['verse']}',
        verse['text'],
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_verse_channel',
            'Daily Bible Verse',
            channelDescription: 'Daily Bible Verse Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload:
        'verse|${verse['book']}|${verse['chapter']}|${verse['verse']}',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint(
        "Daily verse scheduled: ${verse['book']} ${verse['chapter']}:${verse['verse']}",
      );
    } catch (e) {
      debugPrint("Daily verse schedule failed: $e");
    }
  }
  // PRAYER
  static Future<void> scheduleMorningPrayer() async {
    final timeList = await SettingsService.getMorningPrayerTime();

    final prayer =
    await PrayerService.getTodayMorningPrayer();

    if (prayer == null) return;

    await _schedulePrayer(
      10,
      "🌅 ${prayer['title']}",
      prayer['content'],
      timeList[0],
      timeList[1],
    );
  }

  static Future<void> scheduleEveningPrayer() async {
    final timeList = await SettingsService.getEveningPrayerTime();

    final prayer =
    await PrayerService.getTodayEveningPrayer();

    if (prayer == null) return;

    await _schedulePrayer(
      12,
      "🌙 ${prayer['title']}",
      prayer['content'],
      timeList[0],
      timeList[1],
    );
  }

  static Future<void> _schedulePrayer(
      int id,
      String title,
      String body,
      int hour,
      int minute,
      ) async {
    try {
      await notifications.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: "prayer|$title|$body",
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Prayer schedule failed: $e");
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ====================== WORKING INSTANT METHODS ======================
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hekan_channel',
      'HEKAN Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await notifications.show(1, '🙏 HEKAN Bible', 'Test notification working 🎉', details);
  }

  static Future<void> showDailyVerse() async {
    final version =
    await SettingsService.getBibleVersion();

    final daily =
    await BibleService.getTodaysVerses(version);

    final verse =
        (daily["verses"] as List<Map<String, dynamic>>).first;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_verse_channel',
      'Daily Bible Verse',
      importance: Importance.max,
      priority: Priority.high,
    );
    final NotificationDetails details = NotificationDetails(android: androidDetails);

    await notifications.show(
      2,
      '📖 ${verse['book']} ${verse['chapter']}:${verse['verse']}',
      verse['text'],
      details,
      payload:
      'verse|${verse['book']}|${verse['chapter']}|${verse['verse']}',
    );
  }

  // Test schedule in 1 minute (FIXED)
  static Future<void> scheduleTestInOneMinute() async {
    final now = tz.TZDateTime.now(tz.local);
    final testTime = now.add(const Duration(minutes: 1));

    try {
      await notifications.zonedSchedule(
        99,
        '🧪 Test Scheduled Notification',
        'This should appear in about 1 minute',
        testTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Changed to exact
      );
      debugPrint("Test notification scheduled for ${testTime.hour}:${testTime.minute}");
    } catch (e) {
      debugPrint("Test schedule failed: $e");
    }
  }

}