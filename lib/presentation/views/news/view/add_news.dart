import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/data/const/list_news.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/presentation/widgets/button_image.dart';
import 'package:lammah/presentation/widgets/button_style.dart';
import 'package:lammah/presentation/widgets/drop2.dart';
import 'package:lammah/presentation/widgets/input_new_item.dart';

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

  bool value = false;

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
                  ExpansionTile(
                    title: Text(
                      'source',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    children: [
                      CheckboxListTile.adaptive(
                        value: value,
                        onChanged: (val) {
                          setState(() {
                            value = val!;
                          });
                        },
                        title: Text(
                          'me',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      value
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: InputNewItem(
                                    title: 'Name',
                                    controller: sourceController,
                                    isValidator: false,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: InputNewItem(
                                    title: 'Image Link',
                                    controller: sourceController,
                                    isValidator: false,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    context.read<AuthCubit>().pickImage(
                                      title: 'Gallery',
                                    );
                                  },
                                  icon: const Icon(Icons.camera),
                                ),
                                SizedBox(height: height * .1),
                              ],
                            ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: height * .07),
                      MyCustomDropdown(items: ListNews.category),
                    ],
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
