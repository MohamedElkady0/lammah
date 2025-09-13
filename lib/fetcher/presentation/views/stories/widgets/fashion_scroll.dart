import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/cart/cart_point.dart';

class FashionScroll extends StatelessWidget {
  const FashionScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '<',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Expanded(child: SizedBox()),
                Text(
                  'موضه',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(children: [for (int i = 0; i < 10; i++) CartPoint()]),
          ),
        ],
      ),
    );
  }
}
