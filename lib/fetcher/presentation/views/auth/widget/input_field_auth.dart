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
    this.validator,
  });

  final String title;
  final IconData icon;
  final void Function()? onPressed;
  final void Function(String?)? onSaved;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 4.0),
        TextFormField(
          onSaved: onSaved,
          validator:
              validator ??
              (val) {
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

            prefixIcon: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                size: Theme.of(context).iconTheme.size,
                color: Theme.of(context).iconTheme
                    .copyWith(color: Theme.of(context).colorScheme.onPrimary)
                    .color,
              ),
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onPrimary,
                width: 3.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
