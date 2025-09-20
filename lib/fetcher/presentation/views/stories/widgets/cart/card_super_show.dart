import 'package:flutter/material.dart';

class CardSuperShow extends StatelessWidget {
  const CardSuperShow({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Image.network(
            'https://ae01.alicdn.com/kf/S37d3e913e5114086b6f37878c4a29069L.jpg',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * .5,
            height: MediaQuery.of(context).size.height * 0.3,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'EGP3,062.74',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Theme.of(context).colorScheme.onPrimary,
                  decorationThickness: 1,
                  decorationStyle: TextDecorationStyle.solid,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'EGP1,378.37',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 177, 12, 0),
            ),
            child: Text(
              ' %53 خصم',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
