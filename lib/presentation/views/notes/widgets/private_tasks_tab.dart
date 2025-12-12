import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/domian/tasks/tasks_cubit.dart';
import 'package:intl/intl.dart';

class PrivateTasksTab extends StatefulWidget {
  const PrivateTasksTab({super.key});

  @override
  State<PrivateTasksTab> createState() => _PrivateTasksTabState();
}

class _PrivateTasksTabState extends State<PrivateTasksTab> {
  @override
  void initState() {
    super.initState();
    // تحميل المهام عند فتح التبويب
    context.read<TasksCubit>().loadPrivateTasks();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        if (state is TasksLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PrivateTasksLoaded) {
          if (state.tasks.isEmpty) {
            return const Center(child: Text("لا توجد مهام خاصة."));
          }
          return ListView.builder(
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return CheckboxListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Text(
                  DateFormat('yyyy/MM/dd hh:mm a').format(task.deadline),
                ),
                value: task.isCompleted,
                onChanged: (val) {
                  // تحديث الحالة
                  context.read<TasksCubit>().toggleTaskStatus(task.id, val!);
                },
              );
            },
          );
        }
        if (state is TasksError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text("جاري التحميل..."));
      },
    );
  }
}
