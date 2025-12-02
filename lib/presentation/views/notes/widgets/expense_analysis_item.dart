import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lammah/data/model/category.dart';
import 'package:lammah/presentation/views/notes/view/category_details_page.dart';
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
                  style: GoogleFonts.rokkitt(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  NumberFormat.currency(symbol: '\$').format(amount),
                  style: GoogleFonts.rokkitt(
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
                backgroundColor: Colors.white.withAlpha(200),
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
