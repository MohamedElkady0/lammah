import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/cart/cart_point.dart';

class BigSave extends StatelessWidget {
  const BigSave({super.key});

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
                  'Big',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ' %80 ماركات كبيره َ خصم اضافى',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
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
