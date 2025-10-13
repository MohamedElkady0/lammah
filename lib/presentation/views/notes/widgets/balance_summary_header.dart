import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lammah/presentation/views/notes/widgets/mini_chartItem.dart';

class BalanceSummaryHeader extends StatelessWidget {
  const BalanceSummaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // محاكاة للبيانات
    final totalAmount = '10,000\$';

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        // تدرج لوني جذاب للخلفية
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.tertiary, // أو لون أفتح قليلاً من الـ primary
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(300),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الرصيد الحالي',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            totalAmount,
            style: GoogleFonts.ptSansNarrow(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // شريط التحليلات المصغر (بديل DivCash)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                return MiniChartItem(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
