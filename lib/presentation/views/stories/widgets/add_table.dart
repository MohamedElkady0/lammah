import 'package:flutter/material.dart';

class SpecFieldControllers {
  final TextEditingController keyController;
  final TextEditingController valueController;

  SpecFieldControllers()
    : keyController = TextEditingController(),
      valueController = TextEditingController();
}

class AddTable extends StatefulWidget {
  const AddTable({super.key});

  @override
  State<AddTable> createState() => _AddTableState();
}

class _AddTableState extends State<AddTable> {
  final List<SpecFieldControllers> _specFields = [];
  final String productId = "unique_product_id_123"; // ID المنتج للتجربة

  @override
  void initState() {
    super.initState();
    // ابدأ بصف فارغ واحد
    _addSpecField();
  }

  void _addSpecField() {
    setState(() {
      _specFields.add(SpecFieldControllers());
    });
  }

  void _removeSpecField(int index) {
    setState(() {
      _specFields[index].keyController.dispose();
      _specFields[index].valueController.dispose();
      _specFields.removeAt(index);
    });
  }

  // Future<void> _saveSpecifications() async {

  //   final messenger = ScaffoldMessenger.of(context);
  //   // 1. تجميع البيانات في Map

  //   Map<String, String> specificationsMap = {};
  //   for (var field in _specFields) {
  //     final key = field.keyController.text.trim();
  //     final value = field.valueController.text.trim();
  //     if (key.isNotEmpty && value.isNotEmpty) {
  //       specificationsMap[key] = value;
  //     }
  //   }

  //   if (specificationsMap.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('الرجاء إدخال مواصفة واحدة على الأقل')),
  //     );
  //     return;
  //   }

  //   // 2. رفع البيانات إلى Firestore
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('products')
  //         .doc(productId)
  //         .set(
  //           {
  //             'productName': 'Laptop XYZ', // كمثال
  //             'specifications': specificationsMap, // هنا يتم حفظ المواصفات
  //           },
  //           SetOptions(merge: true),
  //         ); // استخدم merge لتحديث المواصفات فقط دون حذف بيانات المنتج الأخرى

  //   messenger.showSnackBar(const SnackBar(content: Text('تم حفظ المواصفات بنجاح!')));
  //   } catch (e) {
  //    messenger.showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _specFields.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    controller: _specFields[index].keyController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      labelText: 'اسم المواصفة',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    controller: _specFields[index].valueController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      labelText: 'قيمة المواصفة',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  onPressed: () => _removeSpecField(index),
                ),

                // IconButton(
                //   icon: const Icon(Icons.save),
                //   onPressed: _saveSpecifications,
                // ),
                IconButton(
                  onPressed: _addSpecField,
                  tooltip: 'إضافة صف جديد',
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
