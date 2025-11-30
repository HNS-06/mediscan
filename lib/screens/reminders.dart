import 'package:flutter/material.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderService _service = ReminderService();
  final _titleCtl = TextEditingController();
  final _bodyCtl = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _daily = false;

  @override
  void initState() {
    super.initState();
    NotificationService().init();
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
  }

  Future<void> _addReminder() async {
    final title = _titleCtl.text.trim();
    final body = _bodyCtl.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
    final id = DateTime.now().millisecondsSinceEpoch % 100000;

    final reminder = Reminder(id: id, title: title, body: body.isEmpty ? 'Medication reminder' : body, dateTime: scheduled, repeatsDaily: _daily);
    await _service.addReminder(reminder);
    _titleCtl.clear();
    _bodyCtl.clear();
    setState(() {});
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _selectedTime);
    if (t != null) setState(() => _selectedTime = t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders'), backgroundColor: Colors.purple),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleCtl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: _bodyCtl, decoration: const InputDecoration(labelText: 'Note (optional)')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Time: ${_selectedTime.format(context)}')),
                TextButton(onPressed: _pickTime, child: const Text('Pick')),
              ],
            ),
            Row(
              children: [
                const Text('Repeat daily'),
                Switch(value: _daily, onChanged: (v) => setState(() => _daily = v)),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _addReminder, child: const Text('Add Reminder')),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Reminder>>(
                future: _service.getReminders(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final items = snap.data!;
                  if (items.isEmpty) return const Center(child: Text('No reminders yet'));
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final r = items[i];
                      return ListTile(
                        title: Text(r.title),
                        subtitle: Text('${r.dateTime.toLocal()}${r.repeatsDaily ? ' • Daily' : ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.snooze),
                              onPressed: () async {
                                await _service.snooze(r.id, 10);
                                setState(() {});
                              },
                              tooltip: 'Snooze 10 min',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _service.removeReminder(r.id);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
