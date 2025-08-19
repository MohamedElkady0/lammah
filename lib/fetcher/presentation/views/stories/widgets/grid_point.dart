import 'package:flutter/material.dart';
import 'package:lammah/core/cart/cart_point.dart';

class GridPoint extends StatelessWidget {
  const GridPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        return CartPoint();
      },
    );
  }
}
