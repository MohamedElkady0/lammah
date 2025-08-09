import 'package:flutter/material.dart';

class CustomPicker extends StatefulWidget {
  const CustomPicker({super.key});

  @override
  State<CustomPicker> createState() => _CustomPickerState();
}

class _CustomPickerState extends State<CustomPicker> {
  DateTime currentdate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DatePickerDialog(
      initialDate: currentdate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      currentDate: currentdate,
    );
  }
}
