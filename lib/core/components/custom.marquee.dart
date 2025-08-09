import 'package:flutter/material.dart';

import 'package:marquee/marquee.dart';

class CustomMarquee extends StatelessWidget {
  const CustomMarquee({super.key});

  @override
  Widget build(BuildContext context) {
    return Marquee(
      text: 'Some sample text that takes some space.',
      style: const TextStyle(fontWeight: FontWeight.bold),
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 20.0,
      velocity: 100.0,
      pauseAfterRound: const Duration(seconds: 1),
      startPadding: 10.0,
      accelerationDuration: const Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }
}
