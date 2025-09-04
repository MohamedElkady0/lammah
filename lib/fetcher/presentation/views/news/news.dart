import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/news/widget/app_bar_news.dart';
import 'package:lammah/fetcher/presentation/widgets/drawer_main.dart';

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      drawer: DrawerMain(),
      body: SafeArea(
        child: SingleChildScrollView(child: Column(children: [AppBarNews()])),
      ),
    );
  }
}
