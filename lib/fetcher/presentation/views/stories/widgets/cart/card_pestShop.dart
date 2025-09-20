import 'package:flutter/material.dart';

class CardPestShop extends StatelessWidget {
  const CardPestShop({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.network(
            'https://ae01.alicdn.com/kf/S30f4f63854e24382874934a9b13dea0eG.jpg',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * .45,
            height: MediaQuery.of(context).size.height * 0.3,
          ),
          const SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width * .45,
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.amber[700]),
            child: Text(
              'EGP957.97',
              softWrap: true,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
