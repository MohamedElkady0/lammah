import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/cart/card_grid.dart';

class GridPoint extends StatelessWidget {
  const GridPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        return CardGrid();
      },
    );
  }
}
