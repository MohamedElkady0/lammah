import 'package:flutter/material.dart';
import 'package:lammah/core/utils/auth_string.dart';

class InputFieldAuth extends StatelessWidget {
  const InputFieldAuth({
    super.key,
    required this.title,
    required this.icon,

    this.onSaved,
    this.keyboardType,
    required this.obscureText,
    this.controller,
    this.onPressed,
    this.onChanged,
  });

  final String title;
  final IconData icon;
  final void Function()? onPressed;
  final void Function(String?)? onSaved;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      validator: (val) {
        if (title == AuthString.name) {
          if (val == null || val.isEmpty) {
            return AuthString.enterName;
          }
          return null;
        } else if (title == AuthString.email) {
          if (val == null || val.isEmpty) {
            return AuthString.enterEmail;
          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
            return AuthString.enterValidEmail;
          }
          return null;
        } else if (title == AuthString.password) {
          if (val == null || val.isEmpty) {
            return AuthString.enterPassword;
          } else if (val.length < 6) {
            return AuthString.enterValidPassword;
          }
          return null;
        } else if (title == AuthString.confirmPassword) {
          if (val == null || val.isEmpty) {
            return AuthString.enterConfirmPassword;
          } else if (controller != null && val != controller!.text) {
            return AuthString.enterValidConfirmPassword;
          }
          return null;
        } else {
          return null;
        }
      },
      onChanged: onChanged,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        hintText: title,
        prefixIcon: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: Theme.of(context).iconTheme.size,
            color: Theme.of(context).iconTheme.color!.withAlpha(100),
          ),
        ),

        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primaryContainer,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
