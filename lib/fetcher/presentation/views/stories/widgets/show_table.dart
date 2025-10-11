import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductScreen extends StatelessWidget {
  final String productId = "unique_product_id_123"; // نفس ID المنتج

  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get(),
      builder: (context, snapshot) {
        // حالة التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // حالة الخطأ
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text('لا يمكن تحميل البيانات أو المنتج غير موجود'),
          );
        }

        // حالة النجاح
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final Map<String, dynamic> specifications =
            data['specifications'] ?? {};

        if (specifications.isEmpty) {
          return const Center(child: Text('لا توجد مواصفات لهذا المنتج'));
        }

        final specList = specifications.entries.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                data['productName'] ?? 'اسم المنتج',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'المواصفات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 20, thickness: 1),
            Expanded(
              child: ListView.builder(
                itemCount: specList.length,
                itemBuilder: (context, index) {
                  final entry = specList[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    color: index.isEven ? Colors.grey.shade100 : Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2, // أعطِ القيمة مساحة أكبر
                          child: Text(
                            '${entry.value}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Expanded(
                          flex: 3, // أعطِ الاسم مساحة أكبر قليلاً
                          child: Text(
                            entry.key,
                            textAlign: TextAlign.right, // لمحاذاة النص لليمين
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

//حلل هذه المشكله منطقيا .. فكر خطوه بخطوه
