import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/button_style.dart';
import 'package:lammah/fetcher/presentation/views/stories/widgets/input_new_shop.dart';

class NewShop extends StatelessWidget {
  const NewShop({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(title: const Text('new Item'), centerTitle: true),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10.0),

                const SizedBox(height: 10.0),
                InputNewShop(
                  title: 'title',
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                ),
                const SizedBox(height: 10.0),
                InputNewShop(
                  title: 'description',
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                ),

                const SizedBox(height: 10.0),
                InputNewShop(
                  title: 'price',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 10.0),
                ButtonAppStyle(title: 'save', icon: Icons.save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
