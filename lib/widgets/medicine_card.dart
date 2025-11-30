import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String medicineName;
  final String dosage;
  final String frequency;
  final String purpose;

  const MedicineCard({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.purpose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  medicineName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Dosage: $dosage', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 16),
                const Icon(Icons.repeat, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Frequency: $frequency', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Purpose: $purpose',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}