import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class MyCustomDropdown extends StatefulWidget {
  const MyCustomDropdown({super.key, required this.items});
  final List<String> items;
  @override
  State<MyCustomDropdown> createState() => _MyCustomDropdownState();
}

class _MyCustomDropdownState extends State<MyCustomDropdown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      isExpanded: true,
      hint: Text(
        'اختر عنصراً',
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      items: widget.items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          )
          .toList(),
      value: selectedValue,
      onChanged: (value) {
        setState(() {
          selectedValue = value;
        });
      },

      buttonStyleData: ButtonStyleData(
        height: 50,
        width: 200,
        padding: const EdgeInsets.only(left: 14, right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black26),
        ),
      ),

      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).colorScheme.primary.withAlpha(200),
        ),

        offset: const Offset(0, -5),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: WidgetStateProperty.all(6),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
      ),
    );
  }
}
