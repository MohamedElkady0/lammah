import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:lammah/fetcher/presentation/views/auth/view/welcome_page.dart';
import 'package:lammah/fetcher/presentation/views/chat/chat_home.dart';
import 'package:lammah/fetcher/presentation/views/enjoyment/enjoyment.dart';
import 'package:lammah/fetcher/presentation/views/home/widget/nav_bar.dart';
import 'package:lammah/fetcher/presentation/views/news/news.dart';
import 'package:lammah/fetcher/presentation/views/stories/shop.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [ChatW(), News(), Shop(), Enjoyment()];
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
            (route) => false,
          );
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Center(child: pages.elementAt(_currentIndex)),
          bottomNavigationBar: NavBar(
            currentIndex: _currentIndex,
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
