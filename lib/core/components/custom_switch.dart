import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool _swVal = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            color: _swVal ? Colors.black : Colors.black26,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.all(40), child: Text('Light')),
              Switch(
                value: _swVal,
                onChanged: (bool value) {
                  setState(() {
                    _swVal = value;
                  });
                },
                // activeColor: Colors.teal,
                // activeTrackColor: Colors.amber,
                inactiveThumbColor: Colors.blue,
                inactiveTrackColor: Colors.black26,
              ),
              const Padding(padding: EdgeInsets.all(40), child: Text('Dark')),
            ],
          ),
        ],
      ),
    );
  }
}
