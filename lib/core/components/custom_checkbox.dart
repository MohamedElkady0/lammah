import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({super.key});

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool js = false;
  bool cSharp = false;
  bool python = false;

  String get txt {
    String str = 'You Selected:\n';
    if (js == true) str += 'Javascript\n';
    if (cSharp == true) str += 'C#\n';
    if (python == true) {
      str += 'Python\n';
    } else {
      str += 'None\n';
    }

    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          const Text('Select All The Programing Languages You Know:'),
          Row(
            children: [
              Checkbox(
                value: js,
                onChanged: (value) {
                  setState(() {
                    js = value!;
                  });
                },
              ),
              const Text('JS'),
            ],
          ),
          CheckboxListTile(
            value: cSharp,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              setState(() {
                cSharp = value!;
              });
            },
            title: const Text('C#'),
          ),
          Row(
            children: [
              Checkbox(
                value: python,
                onChanged: (value) {
                  setState(() {
                    python = value!;
                  });
                },
              ),
              const Text('Python'),
            ],
          ),
          ElevatedButton(
            child: const Text('Apply!'),
            onPressed: () {
              var ad = AlertDialog(
                title: const Text('Thank You For Applying!'),
                content: Text(txt),
              );
              showDialog(context: context, builder: (_) => ad);
            },
          ),
        ],
      ),
    );
  }
}
