import 'package:flutter/material.dart';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

// #1 Toast
void buildToast(BuildContext ctx) {
  showToast(
    'Pink/Amber',
    backgroundColor: Colors.amber,
    textStyle: const TextStyle(color: Colors.pink),
    context: ctx,
    animation: StyledToastAnimation.scale,
    reverseAnimation: StyledToastAnimation.fade,
    position: StyledToastPosition.center,
    animDuration: const Duration(seconds: 1),
    duration: const Duration(seconds: 4),
    curve: Curves.elasticOut,
    reverseCurve: Curves.linear,
  );
}

// #2 AlertDialog
void buildDialog(BuildContext ctx) {
  showDialog(
    context: ctx,
    builder: (innerContext) => AlertDialog(
      title: const Text('Dialog Title'),
      content: const SizedBox(
        height: 150,
        child: Column(
          children: [
            Divider(color: Colors.black),
            Text('Dialog Text Appear Here You Can type AnyThing You Want!'),
            SizedBox(height: 7),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Close !', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(innerContext).pop();
          },
        ),
      ],
    ),
    barrierDismissible: false,
    barrierColor: Colors.red[300],
  );
}

// #3 SnackBar
void buildSnackBar(BuildContext ctx, onUndo) {
  final sBar = SnackBar(
    action: SnackBarAction(
      textColor: Colors.black,
      label: 'Undo!',
      onPressed: onUndo,
    ),
    content: const Text('SnackBar Text'),
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.red,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );
  ScaffoldMessenger.of(ctx).showSnackBar(sBar);
}

// #4 Flushbar
void buildFlushBar(BuildContext ctx) {
  Flushbar(
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    mainButton: TextButton(
      child: const Text('Close!'),
      onPressed: () {
        Navigator.of(ctx).pop();
      },
    ),
    icon: const Icon(Icons.info, color: Colors.white),
    backgroundColor: Colors.amber,
    title: 'This Is The Title',
    messageText: const Text(
      'This Is The Message',
      style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
    ),
  ).show(ctx);
}

// #5 TimePicker
void buildTimePicker(BuildContext ctx) {
  showTimePicker(context: ctx, initialTime: TimeOfDay.now());
}

// #6 DatePicker
void builDatePicker(BuildContext ctx) {
  showDatePicker(
    context: ctx,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    initialDate: DateTime.now(),
  );
}

// #7 DateRangePicker
void builDateRangePicker(BuildContext ctx) {
  showDateRangePicker(
    context: ctx,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );
}
