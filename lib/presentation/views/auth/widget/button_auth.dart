import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lammah/core/config/config_app.dart';

class ButtonAuth extends StatelessWidget {
  const ButtonAuth({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed,
    required this.isW,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isW;

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);

    double width = ConfigApp.width;

    return SizedBox(
      width: isW ? width * 0.8 : width * .4,
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          size: Theme.of(context).iconTheme.size,
          color: Theme.of(context).colorScheme.onTertiary,
        ),
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.primary.withAlpha(40),
          ),
        ),
        onPressed: onPressed,
        label: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
