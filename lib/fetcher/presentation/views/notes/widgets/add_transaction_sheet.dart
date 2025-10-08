import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/fetcher/data/model/category.dart';
import 'package:lammah/fetcher/data/model/transaction.dart';
import 'package:lammah/fetcher/domian/transaction/transaction_cubit.dart';
import 'package:uuid/uuid.dart';

class AddTransactionSheet extends StatefulWidget {
  final DateTime selectedDate;
  const AddTransactionSheet({super.key, required this.selectedDate});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  TransactionType selectedType = TransactionType.expense;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = defaultCategories[0];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إضافة معاملة جديدة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'المبلغ'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'الوصف'),
            ),
            DropdownButton<Category>(
              value: _selectedCategory,
              onChanged: (Category? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: defaultCategories.map<DropdownMenuItem<Category>>((
                Category category,
              ) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                if (amount > 0 && _selectedCategory != null) {
                  final newTransaction = Transaction(
                    id: Uuid().v4(),
                    title: _titleController.text,
                    amount: amount,
                    date: widget.selectedDate,
                    type: selectedType,
                    category: _selectedCategory!,
                  );
                  context.read<TransactionCubit>().addTransaction(
                    newTransaction,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
