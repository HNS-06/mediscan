import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class Reminder {
  final int id;
  final String title;
  final String body;
  final DateTime dateTime;
  final bool repeatsDaily;

  Reminder({required this.id, required this.title, required this.body, required this.dateTime, this.repeatsDaily = false});

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'dateTime': dateTime.toIso8601String(),
        'repeatsDaily': repeatsDaily,
      };

  factory Reminder.fromMap(Map<String, dynamic> map) => Reminder(
        id: map['id'] as int,
        title: map['title'] as String,
        body: map['body'] as String,
        dateTime: DateTime.parse(map['dateTime'] as String),
        repeatsDaily: map['repeatsDaily'] as bool? ?? false,
      );
}

class ReminderService {
  ReminderService._internal();
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;

  static const String _key = 'reminders_v1';

  final NotificationService _notif = NotificationService();

  Future<List<Reminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? list = prefs.getStringList(_key);
    if (list == null) return [];
    return list.map((s) => Reminder.fromMap(Map<String, dynamic>.from(jsonDecode(s)))).toList();
  }

  Future<void> addReminder(Reminder r) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getReminders();
    final updated = [r, ...items];
    final list = updated.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_key, list);
    await _notif.scheduleNotification(id: r.id, title: r.title, body: r.body, scheduledDate: r.dateTime, repeatsDaily: r.repeatsDaily);
  }

  Future<void> removeReminder(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getReminders();
    final updated = items.where((e) => e.id != id).toList();
    final list = updated.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_key, list);
    await _notif.cancel(id);
  }

  Future<void> snooze(int id, int minutes) async {
    final items = await getReminders();
    final r = items.firstWhere((e) => e.id == id, orElse: () => throw Exception('Not found'));
    final DateTime newTime = DateTime.now().add(Duration(minutes: minutes));
    final newReminder = Reminder(id: id, title: r.title + ' (Snoozed)', body: r.body, dateTime: newTime, repeatsDaily: false);
    await removeReminder(id);
    await addReminder(newReminder);
  }
}
