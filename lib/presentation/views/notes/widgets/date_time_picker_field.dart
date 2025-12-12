import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class DateTimePickerField extends StatefulWidget {
  final Function(DateTime) onDateTimeSelected;
  const DateTimePickerField({super.key, required this.onDateTimeSelected});

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  DateTime? _selectedDateTime;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    // 1. اختيار التاريخ
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    // 2. اختيار الوقت
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 30))),
    );
    if (time == null) return;

    // 3. الدمج
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedDateTime = dateTime;
    });

    // إرسال القيمة للأب
    widget.onDateTimeSelected(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.grey.withAlpha(100),
      onTap: _pickDateTime,
      leading: const Icon(Icons.calendar_today, color: Colors.blue),
      title: Text(
        _selectedDateTime == null
            ? "حدد وقت تنفيذ المهمة"
            : intl.DateFormat(
                'yyyy/MM/dd - hh:mm a',
                'ar',
              ).format(_selectedDateTime!),
        style: TextStyle(
          color: _selectedDateTime == null ? Colors.grey : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}
