import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/notes/widgets/add_task_sheet.dart';
import 'package:lammah/presentation/views/notes/widgets/private_tasks_tab.dart';
import 'package:lammah/presentation/views/notes/widgets/public_tasks_market_tab.dart';

class TasksMainPage extends StatelessWidget {
  const TasksMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: Text(
            "المهام",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.primaryContainer,
            tabs: [
              Tab(
                text: "مهامي الخاصة",
                icon: Icon(
                  Icons.lock_outline,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Tab(
                text: "سوق المهام",
                icon: Icon(
                  Icons.public,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PrivateTasksTab(), // شاشة المهام الخاصة (Local)
            PublicTasksMarketTab(), // شاشة المهام العامة (Cloud)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // فتح شاشة إضافة مهمة (مع خيار تحديد النوع)
            _showAddTaskDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    // هنا تعرض Dialog يطلب من المستخدم اختيار:
    // 1. مهمة شخصية (يفتح شيت الإضافة المحلي)
    // 2. طلب خدمة عامة (يفتح شيت Firestore)
    showModalBottomSheet(context: context, builder: (_) => AddTaskSheet());
  }
}
