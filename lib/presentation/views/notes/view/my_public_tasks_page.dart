import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/function/firestore_tasks_service.dart';
import 'package:lammah/data/model/public_task.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/presentation/views/notes/view/public_task_details_page.dart';

class MyPublicTasksPage extends StatelessWidget {
  const MyPublicTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    String myId = '';
    if (authState is AuthSuccess) {
      myId = authState.userInfo.userId ?? '';
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: Text(
            "نشاطي",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onPrimary.withAlpha(70),
            tabs: [
              Tab(text: "نشرتها"),
              Tab(text: "أعمل عليها"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // التبويب الأول: مهام نشرتها أنا
            _buildTaskList(
              FirestoreTasksService().getMyPostedTasks(myId),
              "لم تنشر أي مهام بعد",
            ),

            // التبويب الثاني: مهام أعمل عليها
            _buildTaskList(
              FirestoreTasksService().getTasksAssignedToMe(myId),
              "لا توجد مهام مسندة إليك",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(Stream<List<PublicTask>> stream, String emptyMsg) {
    return StreamBuilder<List<PublicTask>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(emptyMsg));
        }

        final tasks = snapshot.data!;
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(task.title),
                subtitle: Text(_getStatusText(task.status)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                // لون الحالة
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(task.status),
                  child: Icon(
                    _getStatusIcon(task.status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onTap: () {
                  // فتح التفاصيل (حيث يوجد زر التقييم والدردشة)
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

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'مفتوحة للعروض';
      case 'assigned':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'assigned':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.lock_open;
      case 'assigned':
        return Icons.handshake;
      case 'completed':
        return Icons.check;
      default:
        return Icons.help;
    }
  }
}
