import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/core/utils/string_app.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/presentation/views/auth/view/welcome_page.dart';
import 'package:lammah/presentation/views/home/home.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}
//

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  // late ConnectivityResult _connectivityResult;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _loadDataAndNavigate();
    // _checkInternetConnection();
  }

  // void _checkInternetConnection() async {
  //   List<ConnectivityResult> connectivityResult = await Connectivity()
  //       .checkConnectivity();

  //   if (!mounted) return;

  //   setState(() {
  //     _connectivityResult = connectivityResult[0];
  //   });

  //   if (_connectivityResult == ConnectivityResult.mobile ||
  //       _connectivityResult == ConnectivityResult.wifi) {
  //     if (!mounted) return;

  //     Future.delayed(const Duration(seconds: 5));
  //     Navigator.of(context).pushAndRemoveUntil(
  //       MaterialPageRoute(builder: (context) => HomePage()),
  //       (route) => false,
  //     );
  //   } else {
  //     if (mounted) {
  //       _showNoInternetDialog();
  //     }
  //   }
  // }

  // void _showNoInternetDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text(StringApp.connectInternet),
  //       content: Text(StringApp.noInternet),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text(AuthString.ok),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _loadDataAndNavigate() async {
    // انتظار قليل لظهور الشعار (اختياري)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // === هنا الخطوة المهمة: جلب البيانات ===
      await context.read<AuthCubit>().getUserData();

      if (!mounted) return;
      // الانتقال للخريطة بعد جلب البيانات
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      // الانتقال لشاشة تسجيل الدخول إذا لم يكن مسجلاً
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedStarryBackground()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Image.asset(
                        AuthString.logo,
                        width: 150,
                        height: 150,
                      ),
                    );
                  },
                ),
                const SuperAdvancedAnimatedLogo(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SuperAdvancedAnimatedLogo extends StatefulWidget {
  const SuperAdvancedAnimatedLogo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SuperAdvancedAnimatedLogoState createState() =>
      _SuperAdvancedAnimatedLogoState();
}

class _SuperAdvancedAnimatedLogoState extends State<SuperAdvancedAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final String _text = StringApp.appName;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    for (int i = 0; i < _text.length; i++) {
      final start = i * 0.1;
      final end = start + 0.5;
      _animations.add(
        Tween<double>(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start > 1.0 ? 1.0 : start,
              end > 1.0 ? 1.0 : end,
              curve: Curves.easeInOut,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedLetter(String letter, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _animations[index].value,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds);
            },
            child: Text(
              letter,
              style: Theme.of(context).textTheme.displayLarge!.copyWith(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    blurRadius: 20.0,
                    color: Colors.blueAccent,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> children = [];
    for (int i = 0; i < _text.length; i++) {
      children.add(WidgetSpan(child: _buildAnimatedLetter(_text[i], i)));
    }

    return Text.rich(TextSpan(children: children));
  }
}

class AnimatedStarryBackground extends StatefulWidget {
  const AnimatedStarryBackground({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedStarryBackgroundState createState() =>
      _AnimatedStarryBackgroundState();
}

class _AnimatedStarryBackgroundState extends State<AnimatedStarryBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    final random = Random();
    for (int i = 0; i < 150; i++) {
      final layer = random.nextDouble();
      _stars.add(
        Star(
          size: random.nextDouble() * (layer + 2) + 2,
          top: random.nextDouble(),
          left: random.nextDouble(),
          opacity: random.nextDouble() * 0.5 + 0.5,
          speed: (random.nextDouble() * 2 + 1) * (layer + 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _stars.map((star) {
            final newTop =
                (star.top * MediaQuery.of(context).size.height +
                    _controller.value * star.speed * 500) %
                MediaQuery.of(context).size.height;
            return Positioned(
              top: newTop,
              left: star.left * MediaQuery.of(context).size.width,
              child: Opacity(
                opacity: star.opacity,
                child: Icon(
                  Icons.star,
                  size: star.size * 3,
                  color: Colors.amber,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class Star {
  final double size;
  final double top;
  final double left;
  final double opacity;
  final double speed;

  Star({
    required this.size,
    required this.top,
    required this.left,
    required this.opacity,
    required this.speed,
  });
}
