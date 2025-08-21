import 'package:flutter/material.dart';

class InputNewShop extends StatelessWidget {
  const InputNewShop({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return TextFormField(decoration: InputDecoration(hintText: title));
  }
}
