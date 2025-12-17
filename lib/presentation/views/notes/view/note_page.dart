import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/notes/view/TasksMainPage.dart';
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
          children: [
            SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => TasksMainPage()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(100),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),

                    child: Icon(
                      Icons.note_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
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
