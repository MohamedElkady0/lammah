import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  List imgList = ['images/s1.jpg', 'images/s2.jpg', 'images/s3.jpg'];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget buildContainer(index) {
      return Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentIndex == index ? Colors.redAccent : Colors.green,
        ),
      );
    }

    return ListView(
      children: [
        const SizedBox(height: 30),
        const Text(
          'Slider 1: Initial Page Index 0\n\n',
          textAlign: TextAlign.center,
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 186,
            initialPage: 0,
            autoPlay: true,
            onPageChanged: (index, _) {
              setState(() {
                _currentIndex = index;
              });
            },
            autoPlayInterval: const Duration(seconds: 3),
            enableInfiniteScroll: true,
            enlargeCenterPage: true,
          ),
          items: imgList.map((imageUrl) {
            return SizedBox(
              width: double.infinity,
              //margin: EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset(imageUrl, fit: BoxFit.fill),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [buildContainer(0), buildContainer(1), buildContainer(2)],
        ),
        const SizedBox(height: 30),
        const Text(
          'Slider 2: Initial Page Index 1\n\n',
          textAlign: TextAlign.center,
        ),
        CarouselSlider.builder(
          itemCount: imgList.length,
          itemBuilder: (ctx, int index, _) {
            return SizedBox(
              width: double.infinity,
              //margin: EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset(imgList[index], fit: BoxFit.fill),
            );
          },
          options: CarouselOptions(
            height: 186,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 2),
            enlargeCenterPage: true,
            scrollDirection: Axis.vertical,
            //reverse: true,
            pauseAutoPlayOnTouch: false,
            enableInfiniteScroll: false,
            initialPage: 0,
          ),
        ),
      ],
    );
  }
}
