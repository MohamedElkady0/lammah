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

  final List<GlobalKey<ScaffoldState>> _scaffoldKeys = [
    GlobalKey<ScaffoldState>(),
    GlobalKey<ScaffoldState>(),
    GlobalKey<ScaffoldState>(),
    GlobalKey<ScaffoldState>(),
  ];
  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    final keyToClose = _scaffoldKeys[_currentIndex];

    final scaffoldState = keyToClose.currentState;

    if (scaffoldState == null) {
      debugPrint(
        "!!! ERROR: currentState is NULL. The key is not attached to a Scaffold in page index $_currentIndex.",
      );
    } else {
      if (scaffoldState.isDrawerOpen) {
        scaffoldState.closeDrawer();
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    pages = [
      ChatW(),
      Shop(scaffoldKey: _scaffoldKeys[1]),
      News(scaffoldKey: _scaffoldKeys[2]),
      Enjoyment(scaffoldKey: _scaffoldKeys[3]),
    ];
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
          backgroundColor: Theme.of(context).colorScheme.primary,

          body: IndexedStack(index: _currentIndex, children: pages),

          bottomNavigationBar: NavBar(
            currentIndex: _currentIndex,
            onTabChange: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
