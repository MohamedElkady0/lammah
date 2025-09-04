import 'package:flutter/material.dart';

class InputNewItem extends StatelessWidget {
  const InputNewItem({
    super.key,
    required this.title,
    this.keyboardType,
    this.onSaved,
    this.maxLines,
    this.validator,
    this.controller,
    this.onChanged,
    this.isValidator,
  });

  final String title;
  final TextInputType? keyboardType;
  final void Function(String?)? onSaved;
  final int? maxLines;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool? isValidator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      validator: isValidator == false
          ? null
          : validator ??
                (value) => value == null || value.isEmpty
                    ? '$title is required'
                    : null,
      maxLines: maxLines ?? 1,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      ),
      onSaved: onSaved,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        contentPadding: EdgeInsets.all(10),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
    );
  }
}
