import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/stories/views/new_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/category_buttons_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/grid_point.dart';
import 'package:lammah/fetcher/presentation/widgets/top_widget.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/drawer_shop.dart';
import 'package:lammah/fetcher/presentation/widgets/search_app.dart';
import 'package:lammah/fetcher/presentation/widgets/tap_bar_app.dart';

class Shop extends StatefulWidget {
  const Shop({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  final List<String> imgList = [
    'assets/images/console.png',
    'assets/images/requirements.png',
    'assets/images/translate.png',
  ];

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
        title: Image.asset('assets/images/shopping.png', width: 50),
        centerTitle: true,
      ),
      key: widget.scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.primary,
      drawer: DrawerShop(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SearchApp(),
                Stack(
                  children: [
                    TopWidget(imgList: imgList),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: TapBarApp(
                        tapTitle: [
                          'All',
                          'Featured',
                          'Points Shop',
                          'New Arrivals',
                        ],
                        onPressed: [() {}, () {}, () {}, () {}],
                      ),
                    ),
                  ],
                ),
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
