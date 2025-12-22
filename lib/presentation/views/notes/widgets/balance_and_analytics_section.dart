import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart';
import 'package:lammah/presentation/views/notes/widgets/expense_analysis_item.dart';

class BalanceAndAnalyticsSection extends StatelessWidget {
  const BalanceAndAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TransactionError) {
          return Center(child: Text(state.message));
        }
        if (state is TransactionLoaded) {
          final totalMonthlyExpense = state.monthlyExpensesByCategory.values
              .fold(0.0, (prev, amount) => prev + amount);

          return Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     Theme.of(context).colorScheme.primary,
              //     Theme.of(context).colorScheme.tertiary,
              //   ],
              // ),
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(25),
              // boxShadow: [
              //   BoxShadow(
              //     color: Theme.of(context).colorScheme.primary.withAlpha(300),
              //     blurRadius: 15,
              //     offset: const Offset(0, 8),
              //   ),
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الرصيد القابل للتعديل
                GestureDetector(
                  onTap: () {
                    _showEditBalanceDialog(context);
                  },
                  child: Row(
                    children: [
                      Text(
                        'الرصيد الحالي',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(
                    symbol: '\$',
                  ).format(state.totalBalance),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Divider(color: Theme.of(context).colorScheme.onPrimary),
                const SizedBox(height: 16),
                Text(
                  'مصاريف هذا الشهر',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                // لوحة تحليل المصروفات
                if (state.monthlyExpensesByCategory.isEmpty)
                  Center(
                    child: Text(
                      'لا توجد مصروفات مسجلة هذا الشهر',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                else
                  ...state.monthlyExpensesByCategory.entries.map((entry) {
                    final category = entry.key;
                    final amount = entry.value;
                    final percentage = (amount / totalMonthlyExpense) * 100;
                    return ExpenseAnalysisItem(
                      category: category,
                      amount: amount,
                      percentage: percentage,
                    );
                  }),
              ],
            ),
          );
        }
        // إظهار مؤشر تحميل أو حالة أولية
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // نافذة إدخال الرصيد
  void _showEditBalanceDialog(BuildContext context) {
    final TextEditingController balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("تحديد الرصيد المبدئي"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("أدخل المبلغ المتوفر لديك حالياً (كاش + بنك):"),
              const SizedBox(height: 10),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "المبلغ",
                  hintText: "مثلاً: 5000",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                final double? newBalance = double.tryParse(
                  balanceController.text,
                );
                if (newBalance != null) {
                  // استدعاء دالة الكيوبت لتحديث الرصيد والحفظ
                  context.read<TransactionCubit>().updateInitialBalance(
                    newBalance,
                  );
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("تم تحديث الرصيد المبدئي إلى $newBalance"),
                    ),
                  );
                }
              },
              child: const Text("حفظ"),
            ),
          ],
        );
      },
    );
  }
}
