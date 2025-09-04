import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/widgets/drawer_main.dart';

class Enjoyment extends StatelessWidget {
  const Enjoyment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      drawer: DrawerMain(),
      body: SafeArea(
        child: Center(
          child: Text(
            'Enjoyment',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
