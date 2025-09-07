import 'package:flutter/material.dart';
import 'package:lammah/core/components/custom_dropdown.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/fetcher/presentation/widgets/button_image.dart';
import 'package:lammah/fetcher/presentation/widgets/button_style.dart';
import 'package:lammah/fetcher/presentation/widgets/input_new_item.dart';

class AddNews extends StatefulWidget {
  const AddNews({super.key});

  @override
  State<AddNews> createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    urlController.dispose();
    sourceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double height = ConfigApp.height;

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
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset('assets/images/news1.png', height: height * 0.3),
                  const SizedBox(height: 20),
                  InputNewItem(
                    title: 'title',
                    controller: titleController,
                    isValidator: true,
                  ),
                  const SizedBox(height: 10),
                  InputNewItem(
                    title: 'description',
                    maxLines: 5,
                    controller: descriptionController,
                    isValidator: true,
                  ),
                  const SizedBox(height: 10),
                  InputNewItem(
                    title: 'link image',
                    controller: imageController,
                    isValidator: true,
                  ),
                  const SizedBox(height: 10),
                  InputNewItem(
                    title: 'link',
                    controller: urlController,
                    isValidator: false,
                  ),
                  const SizedBox(height: 10),
                  InputNewItem(
                    title: 'source',
                    controller: sourceController,
                    isValidator: false,
                  ),
                  const SizedBox(height: 10),
                  CustomDropdown(
                    letterList: [
                      'general',
                      'sport',
                      'entertainment',
                      'science',
                      'technology',
                      'business',
                      'health',
                      'lifestyle',
                    ],
                    title: 'category',
                  ),

                  ButtonImage(),
                  const SizedBox(height: 20),

                  ButtonAppStyle(
                    title: "تحميل",
                    onPressed: () {},
                    icon: Icons.upload,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
