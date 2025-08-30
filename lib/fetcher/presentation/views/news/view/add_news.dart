import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/news/widget/button_image.dart';

class AddNews extends StatelessWidget {
  const AddNews({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Add News',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          centerTitle: true,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(children: [ButtonImage()]),
          ),
        ),
      ),
    );
  }
}
