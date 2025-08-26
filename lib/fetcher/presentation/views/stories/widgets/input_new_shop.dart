import 'package:flutter/material.dart';

class InputNewShop extends StatelessWidget {
  const InputNewShop({
    super.key,
    required this.title,
    this.keyboardType,
    this.onSaved,
    this.maxLines,
  });

  final String title;
  final TextInputType? keyboardType;
  final void Function(String?)? onSaved;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines ?? 1,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      ),
      onSaved: onSaved,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
    );
  }
}
