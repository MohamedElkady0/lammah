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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => TasksMainPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
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

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "المهام",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

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
