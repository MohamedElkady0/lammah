import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lammah/fetcher/domian/transaction/transaction_cubit.dart';
import 'package:lammah/fetcher/presentation/views/notes/widgets/expense_analysis_item.dart';

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
                  color: Theme.of(context).colorScheme.primary.withAlpha(300),
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
                  NumberFormat.currency(
                    symbol: '\$',
                  ).format(state.totalBalance),
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
}
