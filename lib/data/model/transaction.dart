import 'package:equatable/equatable.dart';
import 'package:lammah/data/model/category.dart'; // تأكد من المسار

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final Category category;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  // ========== التعديل هنا ==========
  Map<String, dynamic> toMapForDb() {
    return {
      'id': id,
      'title': title,
      'amount': amount, //  تصحيح: استخدم "amount" بدلاً من "content"
      'date': date.toIso8601String(), // الأفضل تخزين التاريخ والوقت كاملاً
      'type': type.name, // طريقة أسهل لتحويل enum إلى string
      'categoryId': category.id, // تصحيح: خزن فقط الـ ID الخاص بالفئة
    };
  }

  // ========== سنحتاج إلى تعديل fromMap لاحقًا ==========
  // factory Transaction.fromMap(Map<String, dynamic> map, List<Category> allCategories) {
  //   // ...
  // }

  @override
  List<Object> get props => [id, title, amount, date, type, category];
}
