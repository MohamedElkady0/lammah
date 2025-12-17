import 'package:flutter/material.dart';

class TextAuth extends StatelessWidget {
  const TextAuth({super.key, required this.data});
  final String data;
  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
