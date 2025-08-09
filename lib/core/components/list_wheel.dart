import 'package:flutter/material.dart';

class CustomListWheel extends StatelessWidget {
  const CustomListWheel({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> nameList = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    List<Color> colorList = List.generate(
      nameList.length,
      (index) => Colors.primaries[index],
    );

    int i = 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ListWheelScrollView(
        itemExtent: 100,
        children: [
          ...nameList.map((String name) {
            return Container(
              decoration: BoxDecoration(
                color: colorList[i++],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              width: double.infinity,
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ],
      ),
    );
  }
}
