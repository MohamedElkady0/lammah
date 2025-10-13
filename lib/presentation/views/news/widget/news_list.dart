import 'package:flutter/material.dart';
import 'package:lammah/data/model/news.dart';
import 'package:lammah/presentation/views/news/widget/cart/card_news2.dart';

class NewsList extends StatelessWidget {
  const NewsList({super.key, required this.news});
  final List<News> news;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: news.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return CartNews2(news: news[index]);
      },
    );
  }
}
