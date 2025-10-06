import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/fetcher/domian/notification/notification_cubit.dart';

class AddReminderSheet extends StatefulWidget {
  final DateTime selectedDate;
  const AddReminderSheet({super.key, required this.selectedDate});

  @override
  _AddReminderSheetState createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  late DateTime _scheduledDateTime;

  @override
  void initState() {
    super.initState();
    _scheduledDateTime = widget.selectedDate;
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledDateTime),
    );
    if (pickedTime != null) {
      setState(() {
        _scheduledDateTime = DateTime(
          _scheduledDateTime.year,
          _scheduledDateTime.month,
          _scheduledDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إضافة تذكير جديد',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'عنوان التذكير'),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'تفاصيل'),
            ),
            ListTile(
              title: Text(
                'وقت التنبيه: ${TimeOfDay.fromDateTime(_scheduledDateTime).format(context)}',
              ),
              trailing: Icon(Icons.edit),
              onTap: _selectTime,
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  context.read<NotificationCubit>().scheduleNotification(
                    title: _titleController.text,
                    body: _bodyController.text,
                    scheduledDateTime: _scheduledDateTime,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم جدولة التذكير بنجاح!')),
                  );
                }
              },
              child: Text('حفظ التذكير'),
            ),
          ],
        ),
      ),
    );
  }
}
