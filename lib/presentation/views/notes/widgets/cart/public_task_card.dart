import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lammah/data/model/public_task.dart';

class PublicTaskCard extends StatelessWidget {
  final PublicTask task;
  const PublicTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // تنسيق التاريخ
    final formattedDate = intl.DateFormat(
      'd MMM, hh:mm a',
      'ar',
    ).format(task.deadline);

    // التحقق هل انتهى الوقت؟
    final isExpired = DateTime.now().isAfter(task.deadline);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isExpired ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: isExpired ? Colors.red : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isExpired)
                  const Text(
                    " (منتهية)",
                    style: TextStyle(color: Colors.red, fontSize: 10),
                  ),
              ],
            ),
          ],
        ),
        trailing: Text(
          "${task.budget}\$",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
