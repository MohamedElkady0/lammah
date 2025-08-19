import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/app_bar_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/category_buttons_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/grid_point.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/header_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/search_shop.dart';

class Shop extends StatelessWidget {
  const Shop({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBarShop(),
            SearchShop(),
            HeaderShop(),
            SizedBox(height: 10),
            CategoryButtonsShop(),
            SizedBox(height: 20),
            GridPoint(),
          ],
        ),
      ),
    );
  }
}
