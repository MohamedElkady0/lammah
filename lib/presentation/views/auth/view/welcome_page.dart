import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/config/fixed_sizes_app.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/presentation/views/auth/view/login_page.dart';
import 'package:lammah/presentation/views/auth/view/phone_page.dart';
import 'package:lammah/presentation/views/auth/view/register_page.dart';
import 'package:lammah/presentation/views/auth/widget/button_auth.dart';
import 'package:lammah/presentation/views/auth/widget/fun_service.dart';
import 'package:lammah/presentation/views/home/home.dart';
import 'package:lammah/presentation/views/splach/splash_view.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  late AnimationController _alignmentController;
  late Animation<Alignment> alignment;
  bool agree = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    _alignmentController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    alignment =
        Tween<Alignment>(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).animate(
          CurvedAnimation(
            parent: _alignmentController,
            curve: Curves.easeInBack,
          ),
        );

    _alignmentController.repeat(reverse: true);

    super.initState();
  }

  @override
  void dispose() {
    _alignmentController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double height = ConfigApp.height;
    double width = ConfigApp.width;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('welcome ${state.userInfo.name}')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.black54,
            body: state is AuthLoading
                ? SplashView()
                : Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _alignmentController,
                        builder: (BuildContext context, Widget? child) {
                          return AlignTransition(
                            alignment: alignment,
                            child: Container(
                              height: height * 0.5,
                              width: width * 0.5,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(AuthString.logo),
                                ),
                              ),
                            ),
                          );
                        },
                        child: SizedBox(),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: height * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AuthString.welcome,
                                style: Theme.of(context).textTheme.displayLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontSize: width * 0.1,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.2),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (BuildContext context, Widget? child) {
                              return Transform.scale(
                                scale: _animation.value,
                                child: Column(
                                  children: [
                                    Hero(
                                      tag: 'Login',
                                      child: ButtonAuth(
                                        isW: true,
                                        title: AuthString.login,
                                        icon: FontAwesomeIcons.rightToBracket,
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    AppSpacing.vSpaceM,
                                    Hero(
                                      tag: 'Register',
                                      child: ButtonAuth(
                                        isW: true,
                                        title: AuthString.register,
                                        icon: FontAwesomeIcons.userAstronaut,
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    AppSpacing.vSpaceM,
                                    ButtonAuth(
                                      isW: true,
                                      title: AuthString.google,
                                      icon: FontAwesomeIcons.google,
                                      onPressed: () async {
                                        final authCubit =
                                            BlocProvider.of<AuthCubit>(context);
                                        final scaffoldMessenger =
                                            ScaffoldMessenger.of(context);

                                        final bool? didAgree = await funService(
                                          context,
                                          initialAgreeValue: agree,
                                        );

                                        if (!mounted) return;

                                        if (didAgree == true) {
                                          setState(() {
                                            agree = true;
                                          });

                                          authCubit.signInWithGoogle();
                                        } else {
                                          if (!mounted) return;

                                          scaffoldMessenger.clearSnackBars();
                                          scaffoldMessenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(AuthString.agree),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    AppSpacing.vSpaceM,
                                    Hero(
                                      tag: 'Phone',
                                      child: ButtonAuth(
                                        isW: true,
                                        title: AuthString.phone,
                                        icon: FontAwesomeIcons.phone,
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PhonePage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const SizedBox(),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
