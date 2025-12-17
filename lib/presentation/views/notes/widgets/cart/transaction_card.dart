import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/model/transaction.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    bool isIncome = transaction.type == TransactionType.income;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          transaction.category.icon,
          color: transaction.category.color,
        ),
        title: Text(
          transaction.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${isIncome ? '+' : '-'} ${transaction.amount}\$',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        // ======== إضافة أيقونة الحذف ========
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[300]),
          onPressed: () {
            context.read<TransactionCubit>().deleteTransaction(transaction.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم حذف المعاملة بنجاح'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
