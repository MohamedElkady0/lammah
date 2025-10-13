import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';

class CardBigsave extends StatelessWidget {
  const CardBigsave({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    var width = ConfigApp.width;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
      child: Column(
        children: [
          Image.network(
            'https://ae01.alicdn.com/kf/S1336856bf1c84b2c9c3dca03d7faa15eK.jpg',
            width: width * 0.33,
            height: width * 0.5,
            fit: BoxFit.cover,
          ),
          SizedBox(height: width * 0.008),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    'EGP2,651.19',
                    style: TextStyle(
                      fontSize: width * 0.02,
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
                    'EGP1,776.12',
                    style: TextStyle(
                      fontSize: width * 0.03,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ConfigApp.height * 0.004),
              Text(
                'وفر EGP875.07',
                style: TextStyle(
                  fontSize: width * 0.03,
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
