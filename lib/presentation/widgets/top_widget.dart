import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class TopWidget extends StatefulWidget {
  const TopWidget({super.key, this.imgList, this.card});

  final List<String>? imgList;
  final Widget? card;

  @override
  State<TopWidget> createState() => _TopWidgetState();
}

class _TopWidgetState extends State<TopWidget> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: widget.imgList?.length ?? 7, //top in news required 7
      itemBuilder: (ctx, int index, _) {
        return widget.imgList != null
            ? Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Image.network(widget.imgList![index], fit: BoxFit.fill),
              )
            : widget.card!;
      },
      options: CarouselOptions(
        viewportFraction: 1,
        height: 186,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        reverse: true,
        pauseAutoPlayOnTouch: false,
        enableInfiniteScroll: true,
        initialPage: 0,
      ),
    );
  }
}
