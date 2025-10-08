import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lammah/fetcher/data/model/category.dart';
import 'package:lammah/fetcher/data/model/transaction.dart';
import 'package:lammah/fetcher/presentation/views/notes/widgets/cart/transaction_card.dart';
// ... وأي imports أخرى

class CategoryDetailsPage extends StatelessWidget {
  final Category category;

  const CategoryDetailsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // هنا، يجب أن تقوم بجلب المعاملات الخاصة بهذه الفئة للشهر الحالي
    // من خلال الـ Cubit الذي بدوره يجلبها من قاعدة البيانات
    // final transactions = context.watch<TransactionCubit>().getTransactionsForCategory(category.id);

    // سنستخدم بيانات وهمية للتوضيح الآن
    final List<Transaction> transactions = [];

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name, style: GoogleFonts.cairo()),
        backgroundColor: category.color,
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          // استخدم TransactionCard الذي أنشأناه سابقًا لعرض كل معاملة
          return TransactionCard(transaction: transaction);
        },
      ),
    );
  }
}
