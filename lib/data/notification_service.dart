import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'models/models.dart';
import 'repository.dart';

/// Schedules local rent-due / overdue reminders (PRD §5.10). Fully offline —
/// no network, no server. The app targets Nepal, so times use Asia/Kathmandu.
class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channelId = 'rent_reminders';

  Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kathmandu'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );

    // Android 13+ runtime permission + iOS permission prompt.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _ready = true;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Rent reminders',
      channelDescription: 'Reminders for rent due and overdue payments',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Reschedules a due-date reminder (9:00 AM local) for every unpaid payment
  /// whose due date is still in the future. Called after data changes.
  Future<void> syncRentReminders(PortfolioSnapshot snapshot) async {
    if (!_ready) return;
    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    var id = 1;
    for (final p in snapshot.payments) {
      if (p.status == PaymentStatus.paid) continue;
      final tenant =
          snapshot.tenantById(p.tenantId) ?? snapshot.activeTenantOf(p.roomId);
      final room = snapshot.roomOf(p.roomId);
      final who =
          '${tenant?.fullName ?? 'Tenant'} · Room ${room?.roomNumber ?? ''}';

      final due = tz.TZDateTime(
          tz.local, p.dueDate.year, p.dueDate.month, p.dueDate.day, 9);
      if (due.isAfter(now)) {
        await _schedule(id++, 'Rent due today', '$who — ${_amount(p)} due', due);
      }
      // Overdue nudge three days after the due date, if still unpaid.
      final overdue = due.add(const Duration(days: 3));
      if (overdue.isAfter(now)) {
        await _schedule(
            id++, 'Rent overdue', '$who is overdue — ${_amount(p)}', overdue);
      }
    }
  }

  String _amount(Payment p) => 'Rs ${p.remaining.toStringAsFixed(0)}';

  Future<void> _schedule(
      int id, String title, String body, tz.TZDateTime when) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}

/// Overridden in main() with an initialized instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('notificationServiceProvider must be overridden');
});
