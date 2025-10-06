import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/stories/views/new_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/big_save.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/category_buttons_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/package_provider.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/fashion_scroll.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/grid_point.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/pest_shop.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/super_show.dart';
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
    'https://imgaz.staticbg.com/banggood/os/202509/20250910015107_622.jpg',
    'https://imgaz.staticbg.com/banggood/os/202509/20250910012009_619.jpg',
    'https://imgaz.staticbg.com/banggood/os/202509/20250910011818_164.jpg',
    'https://imgaz.staticbg.com/banggood/os/202509/20250904025340_968.jpg',
    'https://imgaz.staticbg.com/banggood/os/202509/20250905070054_565.jpg',
    'https://imgaz.staticbg.com/banggood/os/202509/20250902041747_201.jpg',
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
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context).colorScheme.primary,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                CategoryButtonsShop(),
                SizedBox(height: 10),
                BigSave(),
                SizedBox(height: 10),
                PackageProvider(),
                SizedBox(height: 10),
                SuperShow(),
                SizedBox(height: 10),
                FashionScroll(),
                SizedBox(height: 10),
                PestShop(),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'ربما تعجبك ايضا',

                        style: TextStyle(fontSize: 20, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                GridPoint(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
