import 'package:flutter/material.dart';
import 'package:lammah/core/function/firestore_tasks_service.dart';
import 'package:lammah/data/model/public_task.dart';
import 'package:lammah/presentation/views/notes/view/public_task_details_page.dart';

class PublicTasksMarketTab extends StatelessWidget {
  const PublicTasksMarketTab({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم StreamBuilder مباشرة مع الخدمة لجلب البيانات لحظياً
    return StreamBuilder<List<PublicTask>>(
      stream: FirestoreTasksService().getOpenTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("حدث خطأ: ${snapshot.error}"));
        }
        final tasks = snapshot.data ?? [];
        if (tasks.isEmpty) {
          return const Center(child: Text("لا توجد مهام متاحة حالياً."));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(task.title),
                subtitle: Text("الميزانية: ${task.budget}\$"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // الانتقال لصفحة التفاصيل
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicTaskDetailsPage(task: task),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
