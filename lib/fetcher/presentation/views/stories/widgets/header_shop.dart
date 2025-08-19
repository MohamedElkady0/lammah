import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/tap_bar_shop.dart';

class HeaderShop extends StatefulWidget {
  const HeaderShop({super.key});

  @override
  State<HeaderShop> createState() => _HeaderShopState();
}

class _HeaderShopState extends State<HeaderShop> {
  List imgList = [
    'assets/images/console.png',
    'assets/images/requirements.png',
    'assets/images/translate.png',
  ];
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: imgList.length,
          itemBuilder: (ctx, int index, _) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(imgList[index], fit: BoxFit.fill),
            );
          },
          options: CarouselOptions(
            height: 186,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            reverse: true,
            pauseAutoPlayOnTouch: false,
            enableInfiniteScroll: false,
            initialPage: 0,
          ),
        ),
        Positioned(top: 0, left: 0, right: 0, child: TapBarShop()),
      ],
    );
  }
}
