import 'package:flutter/material.dart';
import '../models/prescription_history.dart';
import '../utils/helpers.dart';

class RecentActivityItem extends StatelessWidget {
  final PrescriptionHistory prescription;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const RecentActivityItem({
    super.key,
    required this.prescription,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description, color: Colors.blue, size: 20),
        ),
        title: Text(
          prescription.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              Helpers.truncateText(prescription.extractedText, maxLength: 40),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _getDateText(prescription.scanDate),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            prescription.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: prescription.isFavorite ? Colors.red : Colors.grey,
            size: 20,
          ),
          onPressed: onFavorite,
        ),
        onTap: onTap,
      ),
    );
  }

  String _getDateText(DateTime date) {
    if (Helpers.isToday(date)) {
      return 'Today, ${Helpers.formatTime(date)}';
    } else if (Helpers.isYesterday(date)) {
      return 'Yesterday, ${Helpers.formatTime(date)}';
    } else {
      return Helpers.formatDate(date);
    }
  }
}