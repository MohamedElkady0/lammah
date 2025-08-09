import 'package:flutter/material.dart';

import 'package:percent_indicator/percent_indicator.dart';

class CustomPercentIndicator extends StatelessWidget {
  const CustomPercentIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 10.0,
            percent: 0.8,
            header: const Text('Icon header'),
            center: const Icon(
              Icons.person_pin,
              size: 50.0,
              color: Colors.blue,
            ),
            backgroundColor: Colors.grey,
            progressColor: Colors.blue,
          ),
          const SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 120.0,
            lineWidth: 13.0,
            animation: true,
            percent: 0.7,
            center: const Text(
              '70.0%',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            footer: const Text(
              'Sales this week',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.purple,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: LinearPercentIndicator(
              width: 140.0,
              lineHeight: 14.0,
              percent: 0.5,
              center: const Text('50.0%', style: TextStyle(fontSize: 12.0)),
              trailing: const Icon(Icons.mood),
              barRadius: const Radius.elliptical(40, 20),
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: LinearPercentIndicator(
              width: 170.0,
              animation: true,
              animationDuration: 1000,
              lineHeight: 20.0,
              leading: const Text('left content'),
              trailing: const Text('right content'),
              percent: 0.2,
              center: const Text('20.0%'),
              barRadius: const Radius.circular(20),
              progressColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
