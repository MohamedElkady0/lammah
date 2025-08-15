import 'package:flutter/material.dart';

class BackgroundPage extends StatefulWidget {
  const BackgroundPage({super.key});

  @override
  State<BackgroundPage> createState() => _BackgroundPageState();
}

class _BackgroundPageState extends State<BackgroundPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late Animation<Color?> colorAnim1;
  late Animation<Color?> colorAnim2;
  late Animation<Color?> colorAnim3;

  late Animation<Alignment> topAlignmentAnimation;
  late Animation<Alignment> bottomAlignmentAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    topAlignmentAnimation =
        AlignmentTween(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.decelerate,
          ),
        );

    bottomAlignmentAnimation =
        AlignmentTween(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.decelerate,
          ),
        );

    colorAnim1 =
        ColorTween(
          begin: Colors.deepPurple,
          end: Colors.lightBlueAccent,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.slowMiddle,
          ),
        );

    colorAnim2 = ColorTween(begin: Colors.pinkAccent, end: Colors.greenAccent)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.slowMiddle,
          ),
        );

    colorAnim3 = ColorTween(begin: Colors.amber, end: Colors.redAccent).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.slowMiddle),
    );

    _animationController.repeat(reverse: true);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: topAlignmentAnimation.value,
            end: bottomAlignmentAnimation.value,
            colors: [
              colorAnim1.value ?? Colors.transparent,
              colorAnim2.value ?? Colors.transparent,
              colorAnim3.value ?? Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
