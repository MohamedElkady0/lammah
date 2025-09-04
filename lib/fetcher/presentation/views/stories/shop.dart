import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/app_bar_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/category_buttons_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/grid_point.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/header_shop.dart';
import 'package:lammah/fetcher/presentation/widgets/drawer_main.dart';
import 'package:lammah/fetcher/presentation/widgets/search_shop.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      drawer: DrawerMain(),
      body: SafeArea(
        child: Padding(
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
        ),
      ),
    );
  }
}
