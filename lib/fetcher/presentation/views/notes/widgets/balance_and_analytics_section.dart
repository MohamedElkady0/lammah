import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lammah/fetcher/data/model/category.dart';
import 'package:lammah/fetcher/domian/transaction/transaction_cubit.dart';
import 'package:lammah/fetcher/presentation/views/notes/view/category_details_page.dart';

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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الرصيد القابل للتعديل
                GestureDetector(
                  onTap: () {
                    // هنا يمكن فتح نافذة لتعديل الرصيد المبدئي
                    // _showEditBalanceDialog(context, state.totalBalance);
                  },
                  child: Row(
                    children: [
                      Text(
                        'الرصيد الحالي',
                        style: GoogleFonts.cairo(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${NumberFormat.currency(symbol: '\$').format(state.totalBalance)}',
                  style: GoogleFonts.ptSansNarrow(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  'مصاريف هذا الشهر',
                  style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 10),
                // لوحة تحليل المصروفات
                if (state.monthlyExpensesByCategory.isEmpty)
                  Center(
                    child: Text(
                      'لا توجد مصروفات مسجلة هذا الشهر',
                      style: GoogleFonts.cairo(color: Colors.white),
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
                  }).toList(),
              ],
            ),
          );
        }
        // إظهار مؤشر تحميل أو حالة أولية
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// واجهة عرض عنصر تحليل المصروفات
class ExpenseAnalysisItem extends StatelessWidget {
  final Category category;
  final double amount;
  final double percentage;

  const ExpenseAnalysisItem({
    super.key,
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsPage(category: category),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(category.icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  category.name,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  NumberFormat.currency(symbol: '\$').format(amount),
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(category.color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
