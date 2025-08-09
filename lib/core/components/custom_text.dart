import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SelectableText(
          "I'm A Copiable Text Select Me And See What Gonna Happen!",
          showCursor: true,
          cursorColor: Colors.green,
          cursorWidth: 10,
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 40,
          color: Colors.green,
          child: const Text(
            'This Is A Clipped Text, This Is A Clipped Text, This Is A Clipped Text, This Is A Clipped Text',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 40,
          color: Colors.green,
          child: const Text(
            'This Is A Ellipsis Text, This Is A Ellipsis Text, This Is A Ellipsis Text, This Is A Ellipsis Text',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 40,
          color: Colors.green,
          child: const Text(
            'This Is A Faded Text, This Is A Faded Text, This Is A Faded Text, This Is A Faded Text',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 40,
          color: Colors.green,
          child: const Text(
            'This Is A Visible Text, This Is A Visible Text, This Is A Visible Text, This Is A Visible Text',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}
