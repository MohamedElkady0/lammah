import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/notes/widgets/balance_and_analytics_section.dart';
import 'package:lammah/presentation/views/notes/widgets/interactive_calendar_section.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
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
