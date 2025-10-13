import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';

class CardSuperShow extends StatelessWidget {
  const CardSuperShow({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    var width = ConfigApp.width;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.network(
            'https://ae01.alicdn.com/kf/S37d3e913e5114086b6f37878c4a29069L.jpg',
            fit: BoxFit.cover,
            width: width * .35,
            height: ConfigApp.height * 0.165,
          ),
          SizedBox(height: width * 0.008),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'EGP3,062.74',
                style: TextStyle(
                  fontSize: width * 0.022,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Theme.of(context).colorScheme.onPrimary,
                  decorationThickness: 1,
                  decorationStyle: TextDecorationStyle.solid,
                ),
              ),
              SizedBox(width: width * 0.02),
              Text(
                'EGP1,378.37',
                style: TextStyle(
                  fontSize: width * 0.03,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.008),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 177, 12, 0),
            ),
            child: Text(
              ' %53 خصم',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: width * 0.025,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
