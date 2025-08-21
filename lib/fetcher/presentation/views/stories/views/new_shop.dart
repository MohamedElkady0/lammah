import 'package:flutter/material.dart';

class NewShop extends StatelessWidget {
  const NewShop({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [TextField()]),
          ),
        ),
      ),
    );
  }
}
