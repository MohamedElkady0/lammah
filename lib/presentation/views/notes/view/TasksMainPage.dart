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
        appBar: AppBar(
          title: const Text("المهام"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "مهامي الخاصة", icon: Icon(Icons.lock_outline)),
              Tab(text: "سوق المهام", icon: Icon(Icons.public)),
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
