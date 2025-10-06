import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';

class CardPestShop extends StatelessWidget {
  const CardPestShop({super.key});

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
            'https://ae01.alicdn.com/kf/S30f4f63854e24382874934a9b13dea0eG.jpg',
            fit: BoxFit.cover,
            width: width * .25,
            height: ConfigApp.height * 0.2,
          ),
          const SizedBox(height: 1),
          Container(
            width: width * .25,
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.amber[900]),
            child: Text(
              'EGP957.97',
              softWrap: true,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: width * 0.03,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
