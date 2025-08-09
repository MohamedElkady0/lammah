import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:lammah/fetcher/presentation/views/auth/view/welcome_page.dart';
import 'package:lammah/fetcher/presentation/views/home/home.dart';
import 'package:shimmer/shimmer.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerList();
          }

          if (authSnapshot.hasData && authSnapshot.data != null) {
            final authCubit = context.read<AuthCubit>();

            if (authCubit.state is AuthInitial) {
              authCubit.loadUserData(authSnapshot.data!.uid);
            }

            return BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              HomePage(userInfoData: state.userInfo),
                        ),
                      );
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state is AuthFailure) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (state is AuthLoadingProgress) {
                  return Stack(
                    children: [
                      _buildShimmerList(),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[800],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                          minHeight: 5,
                          value: state.progress,
                        ),
                      ),
                    ],
                  );
                }

                return _buildShimmerList();
              },
            );
          }

          return const WelcomeScreen();
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.blue,
      highlightColor: Colors.white,

      direction: ShimmerDirection.rtl,

      period: const Duration(milliseconds: 500),

      loop: 0,
      child: _buildShimmerListItem(),
    );
  }

  Widget _buildShimmerListItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white54,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.height * 0.05),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.1,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
