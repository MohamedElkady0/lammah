import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lammah/presentation/views/notes/widgets/add_reminder_sheet.dart';
import 'package:lammah/presentation/views/notes/widgets/add_transaction_sheet.dart';

void showAddActionSheet(BuildContext context, DateTime date) {
  final colorScheme = Theme.of(context).colorScheme;
  // تنسيق التاريخ المختار للعرض
  String formattedDate = intl.DateFormat(
    'EEEE, d MMMM yyyy',
    'ar',
  ).format(date);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القائمة مع التاريخ
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'إضافة ليوم:',
              style: GoogleFonts.rokkitt(fontSize: 14, color: Colors.grey),
            ),
            Text(
              formattedDate,
              style: GoogleFonts.rokkitt(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // الخيارات الثلاثة المطلوبة بتصميم جذاب
            // في الملف الذي يحتوي على showAddActionSheet
            // ...
            // استبدل استدعاءات onTap القديمة بالجديدة
            _buildActionOption(
              context,
              icon: Icons.monetization_on_rounded,
              color: Colors.green,
              title: "معاملة مالية",
              subtitle: "أضف دخلاً أو مصروفاً لهذا اليوم",
              onTap: () {
                Navigator.pop(context); // أغلق الـ action sheet أولاً
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddTransactionSheet(selectedDate: date),
                );
              },
            ),
            _buildActionOption(
              context,
              icon: Icons.notifications_active_rounded,
              color: Colors.blueAccent,
              title: "تذكير",
              subtitle: "اضبط تنبيهاً في هذا التاريخ",
              onTap: () {
                Navigator.pop(context);
                // فتح نافذة إضافة تذكير
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddReminderSheet(selectedDate: date),
                );
              },
            ),

            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ), // للحواف السفلية للهواتف الحديثة
          ],
        ),
      );
    },
  );
}

// عنصر واحد في قائمة الخيارات
Widget _buildActionOption(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha(300),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(100),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: GoogleFonts.rokkitt(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.rokkitt(fontSize: 12, color: Colors.grey),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[400],
      ),
    ),
  );
}
