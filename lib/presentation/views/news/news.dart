import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/news/view/add_news.dart';
import 'package:lammah/presentation/views/news/widget/cart/card_news.dart';
import 'package:lammah/presentation/views/news/widget/drawer_news.dart';
import 'package:lammah/presentation/views/news/widget/news_list.dart';
import 'package:lammah/presentation/widgets/top_widget.dart';
import 'package:lammah/presentation/widgets/tap_bar_app.dart';
import 'package:lammah/data/model/news.dart';

class NewsView extends StatelessWidget {
  const NewsView({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    print("News page build: Using key ${scaffoldKey.hashCode}");
    return Scaffold(
      drawer: DrawerNews(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Image.asset('assets/images/logotype.png', width: 50),

        centerTitle: true,
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => AddNews()));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/news (1).png', width: 45),
            ),
          ),
        ],
      ),
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  TopWidget(card: CartNews()),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: TapBarApp(
                      tapTitle: [
                        'Top news',
                        'Live',
                        'Sports',
                        'Wither',
                        'Food',
                      ],
                      onPressed: [() {}, () {}, () {}, () {}, () {}],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              NewsList(news: [News(), News(), News()]),
            ],
          ),
        ),
      ),
    );
  }
}
