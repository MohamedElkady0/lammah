import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/fetcher/domian/notification/notification_cubit.dart';

class AddReminderSheet extends StatefulWidget {
  final DateTime selectedDate;
  const AddReminderSheet({super.key, required this.selectedDate});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  // سنخزن الوقت المختار بشكل منفصل
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    // قم بتهيئة الوقت لوقت لاحق من اليوم الحالي لتجنب "الماضي"
    final now = DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(now.add(const Duration(minutes: 5)));
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
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
              title: Text('وقت التنبيه: ${_selectedTime.format(context)}'),
              trailing: Icon(Icons.edit),
              onTap: () => _selectTime(context),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  // ======== هنا الإصلاح الحاسم ========
                  // ١. ابدأ بالتاريخ المختار من التقويم (بدون وقت)
                  final date = widget.selectedDate;

                  // ٢. أنشئ كائن DateTime جديد يدمج التاريخ الصحيح مع الوقت الصحيح
                  final DateTime scheduledDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  // ٣. تحقق مرة أخرى إذا كان الوقت لا يزال في الماضي
                  if (scheduledDateTime.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('لا يمكن جدولة تذكير في وقت قد مضى!'),
                      ),
                    );
                    return; // أوقف التنفيذ
                  }

                  // ٤. مرر التاريخ والوقت المدمجين بشكل صحيح
                  context.read<NotificationCubit>().scheduleNotification(
                    title: _titleController.text,
                    body: _bodyController.text,
                    scheduledDateTime: scheduledDateTime,
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
