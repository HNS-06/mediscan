import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';
import '../widgets/modern_components.dart';

class RemindersScreenNew extends StatefulWidget {
  const RemindersScreenNew({super.key});

  @override
  State<RemindersScreenNew> createState() => _RemindersScreenNewState();
}

class _RemindersScreenNewState extends State<RemindersScreenNew>
    with TickerProviderStateMixin {
  final ReminderService _service = ReminderService();
  final _titleCtl = TextEditingController();
  final _bodyCtl = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _daily = false;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    NotificationService().init();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _bodyCtl.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _addReminder() async {
    final title = _titleCtl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reminder title')),
      );
      return;
    }

    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final id = DateTime.now().millisecondsSinceEpoch % 100000;

    final reminder = Reminder(
      id: id,
      title: title,
      body: _bodyCtl.text.isEmpty ? 'Reminder' : _bodyCtl.text,
      dateTime: scheduled,
      repeatsDaily: _daily,
    );
    await _service.addReminder(reminder);
    _titleCtl.clear();
    _bodyCtl.clear();
    setState(() => _daily = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder added successfully! 🎉'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _selectedTime);
    if (t != null) {
      setState(() => _selectedTime = t);
    }
  }

  Future<void> _deleteReminder(int id) async {
    await _service.removeReminder(id);
    setState(() {});
  }

  Future<void> _snoozeReminder(int id) async {
    await _service.snooze(id, 5);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder snoozed for 5 minutes ⏰'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add Reminder Form
            _buildAddReminderForm(),
            const SizedBox(height: 32),

            // Reminders List
            _buildRemindersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddReminderForm() {
    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGradientStart.withOpacity(0.2),
                      AppTheme.primaryGradientEnd.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_alert_rounded,
                  color: AppTheme.primaryGradientStart,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Add New Reminder',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _titleCtl,
            label: 'Reminder Title',
            hint: 'e.g., Take Medication',
            icon: Icons.edit_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _bodyCtl,
            label: 'Description (Optional)',
            hint: 'Add notes about this reminder',
            icon: Icons.note_rounded,
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          // Time Picker
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: AppTheme.primaryGradientStart),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminder Time',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedTime.format(context),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Daily Toggle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGradientStart.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _daily ? Icons.repeat_rounded : Icons.calendar_today_rounded,
                      color: _daily ? AppTheme.primaryGradientStart : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repeat Daily',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          _daily ? 'Every day' : 'One time only',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _daily,
                  onChanged: (v) => setState(() => _daily = v),
                  activeColor: AppTheme.primaryGradientStart,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Create Reminder',
            icon: Icons.check_rounded,
            onPressed: _addReminder,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryGradientStart),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryGradientStart,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildRemindersList() {
    return FutureBuilder<List<Reminder>>(
      future: _service.getReminders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: AppTheme.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first reminder above',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        final reminders = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Reminders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _buildReminderCard(reminder);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final color = [
      AppTheme.primaryGradientStart,
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
    ][reminder.id.toInt() % 4];

    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.notifications_active_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reminder.dateTime.hour.toString().padLeft(2, '0')}:${reminder.dateTime.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 12),
                        if (reminder.repeatsDaily)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGradientStart.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Daily',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.primaryGradientStart,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'snooze') {
                    _snoozeReminder(reminder.id);
                  } else if (value == 'delete') {
                    _deleteReminder(reminder.id);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'snooze',
                    child: Row(
                      children: [
                        Icon(Icons.snooze_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Snooze 5m'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (reminder.body.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              reminder.body,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
