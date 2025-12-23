import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lammah/data/model/transaction.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart';
import 'package:lammah/presentation/views/notes/widgets/expense_analysis_item.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lammah/data/service/ai_financial_service.dart';

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
                      const SizedBox(width: 8),
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
                Row(
                  children: [
                    Text(
                      'مصاريف هذا الشهر',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                    // === زر الذكاء الاصطناعي ===
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.auto_awesome, color: Colors.amber),
                      label: Text(
                        "حلل مصاريفي",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onPressed: () {
                        // نمرر المعاملات الحالية من الـ State
                        _showAiAnalysisDialog(context, state.transactions);
                      },
                    ),
                  ],
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
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Text(
            "تحديد الرصيد المبدئي",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "أدخل المبلغ المتوفر لديك حالياً (كاش + بنك):",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "المبلغ",
                  hintText: "مثلاً: 5000",
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "إلغاء",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
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
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      content: Text(
                        "تم تحديث الرصيد المبدئي إلى $newBalance",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                "حفظ",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAiAnalysisDialog(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Row(
            children: [
              Icon(Icons.psychology, color: Colors.purple),
              SizedBox(width: 10),
              Text(
                "المستشار المالي الذكي",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<String>(
              // استدعاء الخدمة هنا
              future: AiFinancialService().getFinancialAdvice(transactions),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 15),
                      Text(
                        "جاري تحليل بياناتك المالية...",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    "خطأ: ${snapshot.error}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                } else {
                  // عرض النتيجة باستخدام Markdown لتنسيق النقاط والعناوين
                  return SingleChildScrollView(
                    child: MarkdownBody(
                      data: snapshot.data ?? "",
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16, color: Colors.black),
                        listBullet: const TextStyle(color: Colors.purple),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "شكراً",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
