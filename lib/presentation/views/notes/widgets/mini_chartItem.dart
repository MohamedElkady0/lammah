import 'package:flutter/material.dart';

class MiniChartItem extends StatelessWidget {
  final int index;
  const MiniChartItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // محاكاة ارتفاعات مختلفة للأعمدة
    double barHeight = (index % 3 == 0) ? 40.0 : (index % 2 == 0 ? 60.0 : 30.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // العمود البياني
          Container(
            height: barHeight,
            width: 8,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(700),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 8),
          // أيقونة أو نص صغير
          Icon(Icons.circle, size: 8, color: Colors.white.withAlpha(500)),
        ],
      ),
    );
  }
}
