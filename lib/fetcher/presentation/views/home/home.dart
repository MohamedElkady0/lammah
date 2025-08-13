import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/utils/string_app.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:lammah/fetcher/presentation/views/auth/view/welcome_page.dart';
import 'package:lammah/fetcher/presentation/views/chat/chat_home.dart';
import 'package:lammah/fetcher/presentation/views/enjoyment/enjoyment.dart';
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
    double w = ConfigApp.width;

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
          body: pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            type: BottomNavigationBarType.shifting,
            selectedIconTheme: Theme.of(context).iconTheme.copyWith(
              color: Theme.of(context).colorScheme.onTertiary,
              size: w * 0.08,
            ),
            selectedItemColor: Theme.of(context).colorScheme.onTertiary,
            unselectedItemColor: Theme.of(context).colorScheme.primary,

            unselectedIconTheme: Theme.of(context).iconTheme.copyWith(
              color: Theme.of(context).colorScheme.primary,
              size: w * 0.05,
            ),

            onTap: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            currentIndex: _currentIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: StringApp.chats,
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: StringApp.store,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                label: StringApp.news,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: StringApp.enjoyment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
