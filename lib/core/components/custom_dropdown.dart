import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({
    super.key,
    required this.letterList,
    required this.title,
  });

  final List<String> letterList;
  final String title;

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? _selectedLetter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.07),
          DropdownButton(
            dropdownColor: Theme.of(context).colorScheme.primary.withAlpha(100),
            icon: Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 30,
            ),
            hint: Text(
              'Selected Category',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            value: _selectedLetter,
            items: widget.letterList.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
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
