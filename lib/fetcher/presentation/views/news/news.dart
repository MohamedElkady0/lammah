import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/news/widget/drawer_news.dart';

class News extends StatelessWidget {
  const News({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    print("News page build: Using key ${scaffoldKey.hashCode}");
    return Scaffold(
      drawer: DrawerNews(),
      appBar: AppBar(title: Text('News')),
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(child: Column(children: [])),
      ),
    );
  }
}
