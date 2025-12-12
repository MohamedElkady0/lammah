import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/model/note.dart'; // تأكد من استيراد موديل الملاحظة
import 'package:lammah/domian/notification/notification_cubit.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart'; // استيراد الكيوبت الخاص بالبيانات
import 'package:uuid/uuid.dart'; // لتوليد ID فريد

class AddReminderSheet extends StatefulWidget {
  final DateTime selectedDate;
  const AddReminderSheet({super.key, required this.selectedDate});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // ضبط الوقت الافتراضي بعد 5 دقائق من الآن
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'إضافة تذكير جديد',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان التذكير',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'تفاصيل (اختياري)',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),

            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              tileColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(100),
              leading: Icon(
                Icons.access_time_filled,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'وقت التنبيه: ${_selectedTime.format(context)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 25),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.alarm_add),
                label: const Text('حفظ التذكير'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    // 1. تجهيز التاريخ والوقت
                    final date = widget.selectedDate;
                    final DateTime scheduledDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );

                    if (scheduledDateTime.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لا يمكن جدولة تذكير في وقت قد مضى!'),
                        ),
                      );
                      return;
                    }

                    // 2. إنشاء كائن الملاحظة للحفظ في قاعدة البيانات
                    final newNote = Note(
                      id: const Uuid().v4(),
                      title: _titleController.text,
                      content: _bodyController.text,
                      date: scheduledDateTime,
                      isCompleted: false, // افتراضياً غير مكتملة
                    );

                    context.read<TransactionCubit>().addNote(newNote);

                    // 4. جدولة التنبيه الفعلي (Notification)
                    context.read<NotificationCubit>().scheduleNotification(
                      title: _titleController.text,
                      body: _bodyController.text,
                      scheduledDateTime: scheduledDateTime,
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حفظ الملاحظة وجدولة التنبيه!'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
