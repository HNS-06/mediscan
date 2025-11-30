import 'package:flutter/material.dart';
import '../widgets/health_tips_carousel.dart';
import '../widgets/stat_card.dart';
import 'prescription_history.dart';
import 'prescription_scanner.dart';
import 'lab_report_upload.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _greetingForHour(now.hour);

    final recent = [
      {'title': 'Prescription - Dr. Rao', 'date': 'Nov 28'},
      {'title': 'Lab Report - CBC', 'date': 'Nov 20'},
      {'title': 'Prescription - Dr. Mehta', 'date': 'Nov 10'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.person, size: 30, color: Colors.blue),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickAction(context, Icons.camera_alt, 'Scan', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrescriptionScanner()));
                }),
                _quickAction(context, Icons.upload_file, 'Upload', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LabReportUpload()));
                }),
                _quickAction(context, Icons.history, 'History', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrescriptionHistory()));
                }),
              ],
            ),

            const SizedBox(height: 20),

            // Recent activity
            const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    for (var item in recent)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                        title: Text(item['title']!),
                        subtitle: Text(item['date']!),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Health tips carousel
            const Text('Health Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const HealthTipsCarousel(),

            const SizedBox(height: 20),

            // Statistics cards
            const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(child: StatCard(label: 'Scans this month', value: '8')),
                SizedBox(width: 12),
                Expanded(child: StatCard(label: 'Favorites', value: '3')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: StatCard(label: 'Interactions checked', value: '5')),
                SizedBox(width: 12),
                Expanded(child: StatCard(label: 'Reminders', value: '2')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.blue, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
