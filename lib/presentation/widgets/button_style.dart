import 'package:flutter/material.dart';

class ButtonAppStyle extends StatelessWidget {
  const ButtonAppStyle({
    super.key,
    this.onPressed,
    required this.title,
    this.icon,
  });
  final void Function()? onPressed;
  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 30.0,
        ),
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          backgroundColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
          ),
        ),
        onPressed: onPressed,
        label: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
      ),
    );
  }
}
