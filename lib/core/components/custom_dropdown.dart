import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({super.key});

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? _selectedLetter;
  final List<String> _letterList = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Select a Letter!'),
          const SizedBox(width: 10),
          DropdownButton(
            hint: const Text('A!!!'),
            value: _selectedLetter,
            items: _letterList.map((String item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: (newVal) {
              setState(() {
                _selectedLetter = newVal.toString();
              });
            },
          ),
        ],
      ),
    );
  }
}
