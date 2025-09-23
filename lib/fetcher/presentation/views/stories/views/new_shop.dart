import 'package:flutter/material.dart';
import 'package:lammah/fetcher/data/const/list_shop.dart';
import 'package:lammah/fetcher/presentation/widgets/button_image.dart';
import 'package:lammah/fetcher/presentation/widgets/button_style.dart';
import 'package:lammah/fetcher/presentation/widgets/drop2.dart';
import 'package:lammah/fetcher/presentation/widgets/input_new_item.dart';

class NewShop extends StatefulWidget {
  const NewShop({super.key});

  @override
  State<NewShop> createState() => _NewShopState();
}

class _NewShopState extends State<NewShop> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool value = false;
  bool value1 = false;
  bool value2 = false;

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Add New Shop',
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
                  Image.asset(
                    'assets/images/online-shopping.png',
                    height: 200,
                    fit: BoxFit.fill,
                  ),
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
                    isValidator: false,
                  ),
                  const SizedBox(height: 10),
                  InputNewItem(
                    title: 'link',
                    controller: urlController,
                    isValidator: false,
                  ),
                  const SizedBox(height: 10),
                  InputNewItem(
                    title: 'price',
                    controller: sourceController,
                    isValidator: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      MyCustomDropdown(
                        items: ListShop.category,
                        iconItems: ListShop.iconShop,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  InputNewItem(
                    title: 'count',
                    controller: sourceController,
                    isValidator: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      MyCustomDropdown(
                        items: List.generate(100, (i) {
                          return '$i';
                        }),
                        iconItems: List.generate(100, (i) {
                          return Icons.discount;
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  ExpansionTile(
                    title: Text(
                      'الشحن',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    children: [
                      const SizedBox(height: 10),

                      CheckboxListTile.adaptive(
                        value: value,
                        onChanged: (val) {
                          setState(() => value = val!);
                        },
                        title: Text(
                          'الشحن مجانى',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      InputNewItem(
                        title: 'مصاريف الشحن',
                        controller: sourceController,
                        isValidator: true,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: Text(
                      'الارجاع',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    children: [
                      const SizedBox(height: 10),

                      CheckboxListTile.adaptive(
                        value: value1,
                        onChanged: (val) {
                          setState(() {
                            value1 = val!;
                            if (value1 == true) {
                              value2 = false;
                            }
                          });
                        },
                        title: Text(
                          'ارجاع مجانى',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      CheckboxListTile.adaptive(
                        value: value2,
                        onChanged: (val) {
                          setState(() {
                            value2 = val!;
                            if (value2 == true) {
                              value1 = false;
                            }
                          });
                        },
                        title: Text(
                          'عدم الارجاع',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ExpansionTile(
                    title: Text(
                      'هل تريد عمل باقه',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    children: [const SizedBox(height: 10)],
                  ),
                  const SizedBox(height: 10),

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
