import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextAuth extends StatelessWidget {
  const TextAuth({super.key, required this.data});
  final String data;
  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: GoogleFonts.pragatiNarrow(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
