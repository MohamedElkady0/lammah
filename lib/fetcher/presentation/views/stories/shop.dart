import 'package:flutter/material.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/fetcher/presentation/views/stories/views/new_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/category_buttons_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/grid_point.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/header_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/drawer_shop.dart';
import 'package:lammah/fetcher/presentation/widgets/search_shop.dart';

class Shop extends StatelessWidget {
  const Shop({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const NewShop()));
            },
            child: Image.asset('assets/images/save-money.png', width: 35),
          ),
        ],
        title: Image.asset(AuthString.logo, width: 50),
        centerTitle: true,
      ),
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.primary,
      drawer: DrawerShop(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
