import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/news/widget/app_bar_news.dart';

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [AppBarNews()]));
  }
}
