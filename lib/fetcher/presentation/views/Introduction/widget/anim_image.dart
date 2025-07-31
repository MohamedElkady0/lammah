import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/fetcher/presentation/views/Introduction/data/pageview_data.dart';

class AnimImagePage extends StatefulWidget {
  const AnimImagePage({
    super.key,
    required this.index,
    required this.animationController,
  });

  final int index;
  final AnimationController animationController;

  @override
  State<AnimImagePage> createState() => _AnimImagePageViewState();
}

class _AnimImagePageViewState extends State<AnimImagePage> {
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double width = ConfigApp.width;
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: animation.value,
          child: Image.asset(
            pageViewData[widget.index].image!,
            fit: BoxFit.fill,
            width: width * 0.5,
          ),
        );
      },
    );
  }
}
