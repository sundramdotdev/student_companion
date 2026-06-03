import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/attendance/domain/entities/subject.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String classChannelId = 'class_reminders_channel';
  static const String classChannelName = 'Class Reminders';
  static const String attendanceChannelId = 'attendance_prompts_channel';
  static const String attendanceChannelName = 'Attendance Prompts';
  static const String alertsChannelId = 'low_attendance_alerts_channel';
  static const String alertsChannelName = 'Low Attendance Alerts';

  Future<void> init() async {
    // Initialize Timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          classChannelId,
          classChannelName,
          description: 'Notifications sent 15 minutes before a class starts.',
          importance: Importance.max,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          attendanceChannelId,
          attendanceChannelName,
          description: 'Prompts sent 10 minutes after class ends to log attendance.',
          importance: Importance.max,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          alertsChannelId,
          alertsChannelName,
          description: 'Alerts about low attendance or homework marks.',
          importance: Importance.high,
        ),
      );
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  // Schedule reminders for a list of subjects
  Future<void> scheduleTimetableNotifications(List<Subject> subjects) async {
    // First, cancel all existing scheduled class/attendance notifications
    await cancelAllTimetableNotifications();

    int notificationId = 1000;

    for (final subject in subjects) {
      for (final schedule in subject.schedules) {
        final dayIndex = _getDayOfWeekIndex(schedule.dayOfWeek);
        if (dayIndex == -1) continue;

        // 1. Schedule Class Reminder (15 mins before class start)
        final classReminderTime = _subtractMinutes(
          schedule.startHour,
          schedule.startMinute,
          15,
        );

        final classNotificationId = notificationId++;
        await _scheduleWeeklyNotification(
          id: classNotificationId,
          title: 'Upcoming Class',
          body: '${subject.name} starts in 15 minutes.',
          dayOfWeek: dayIndex,
          hour: classReminderTime.hour,
          minute: classReminderTime.minute,
          channelId: classChannelId,
          channelName: classChannelName,
        );

        // 2. Schedule Attendance Prompt (10 mins after class end)
        final attendancePromptTime = _addMinutes(
          schedule.endHour,
          schedule.endMinute,
          10,
        );

        final attendanceNotificationId = notificationId++;
        await _scheduleWeeklyNotification(
          id: attendanceNotificationId,
          title: 'Log Attendance',
          body: 'Mark your attendance for ${subject.name}.',
          dayOfWeek: dayIndex,
          hour: attendancePromptTime.hour,
          minute: attendancePromptTime.minute,
          channelId: attendanceChannelId,
          channelName: attendanceChannelName,
        );
      }
    }
  }

  Future<void> cancelAllTimetableNotifications() async {
    // Simple way is to cancel notifications within the range of timetable notification IDs
    // Since we start from 1000, we can cancel up to 2000 or just use cancelAll() for simplicity.
    // The instructions say "All data must remain on device... Notifications". We can use cancelAll()
    // but keep custom single alerts if we want.
    await _notificationsPlugin.cancelAll();
  }

  // Show immediate notification (e.g. low attendance alert, assignment reminder, etc.)
  Future<void> showImmediateAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      alertsChannelId,
      alertsChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _notificationsPlugin.show(id, title, body, details);
  }

  // Schedule a specific reminder (e.g. assignment due date)
  Future<void> scheduleSpecificAlert({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      alertsChannelId,
      alertsChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Helpers
  int _getDayOfWeekIndex(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return -1;
    }
  }

  TimeOfDayModel _subtractMinutes(int hour, int minute, int mins) {
    int totalMins = hour * 60 + minute - mins;
    if (totalMins < 0) {
      totalMins += 24 * 60;
    }
    return TimeOfDayModel(
      hour: (totalMins ~/ 60) % 24,
      minute: totalMins % 60,
    );
  }

  TimeOfDayModel _addMinutes(int hour, int minute, int mins) {
    int totalMins = hour * 60 + minute + mins;
    return TimeOfDayModel(
      hour: (totalMins ~/ 60) % 24,
      minute: totalMins % 60,
    );
  }

  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required int hour,
    required int minute,
    required String channelId,
    required String channelName,
  }) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfDayOfWeek(dayOfWeek, hour, minute);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfDayOfWeek(int dayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }
}

class TimeOfDayModel {
  final int hour;
  final int minute;
  TimeOfDayModel({required this.hour, required this.minute});
}
