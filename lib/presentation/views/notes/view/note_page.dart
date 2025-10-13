import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lammah/presentation/views/notes/widgets/balance_and_analytics_section.dart';
import 'package:lammah/presentation/views/notes/widgets/interactive_calendar_section.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام ثيم داكن أنيق (يمكنك تغييره حسب ثيم تطبيقك)
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // خلفية الصفحة الأساسية
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'يومياتي المالية',
          style: GoogleFonts.cairo(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: const [
            // دمجنا الواجهتين في واحدة لتكون أكثر تفاعلية
            BalanceAndAnalyticsSection(),
            SizedBox(height: 20),
            InteractiveCalendarSection(),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
