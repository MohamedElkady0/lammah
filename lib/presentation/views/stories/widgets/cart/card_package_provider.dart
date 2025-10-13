import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';

class CardPackageProvider extends StatelessWidget {
  const CardPackageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    var width = ConfigApp.width;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.network(
            'https://ae01.alicdn.com/kf/S80e41701ea2e455b84072d0bd1d9142by.jpg',
            fit: BoxFit.cover,
            width: width * .35,
            height: ConfigApp.height * 0.1,
          ),
          SizedBox(height: width * 0.008),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    'للواحد',
                    style: TextStyle(
                      fontSize: width * 0.02,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  Text(
                    'EGP9.02',
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ConfigApp.height * 0.004),
              Text(
                'اشترى ${3} قطع او اكثر',
                style: TextStyle(
                  fontSize: width * 0.027,
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
