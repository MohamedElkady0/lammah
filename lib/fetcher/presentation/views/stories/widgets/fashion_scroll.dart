import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/cart/card_fashion.dart';

class FashionScroll extends StatelessWidget {
  const FashionScroll({super.key});

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
          SizedBox(height: width * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(child: SizedBox()),
                InkWell(
                  onTap: () {},
                  child: Text(
                    'موضه',
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(children: [for (int i = 0; i < 10; i++) CardFashion()]),
          ),
        ],
      ),
    );
  }
}
