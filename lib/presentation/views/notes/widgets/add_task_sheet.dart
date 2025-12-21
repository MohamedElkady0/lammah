import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/model/private_task%20.dart';
import 'package:lammah/data/model/public_task.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/tasks/tasks_cubit.dart';
import 'package:uuid/uuid.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  bool isPublic = false; // التبديل بين مهمة عامة وخاصة
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  Widget build(BuildContext context) {
    var user = context.read<AuthCubit>().currentUserInfo;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPublic ? "نشر مهمة عامة" : "إضافة مهمة خاصة",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              SwitchListTile(
                title: Text(
                  "نشر للعامة (طلب خدمة)",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                value: isPublic,
                onChanged: (val) => setState(() => isPublic = val),
              ),

              TextField(
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "العنوان",
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              if (isPublic)
                TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: "الوصف والتفاصيل",
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

              if (isPublic)
                TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: "الميزانية المقترحة",
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),

              // هنا يمكنك إضافة ويدجت اختيار الوقت DateTimePickerField
              ListTile(
                title: Text(
                  _selectedDeadline == null
                      ? "اختر الموعد"
                      : _selectedDeadline.toString(),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _selectedDeadline = date);
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  if (_titleController.text.isNotEmpty &&
                      _selectedDeadline != null) {
                    if (isPublic) {
                      // منطق المهمة العامة
                      final userState = context.read<AuthCubit>().state;
                      if (userState is AuthSuccess) {
                        final task = PublicTask(
                          id: '',
                          ownerId: user?.userId ?? '',
                          ownerName: user?.name ?? '',
                          ownerPhone: user?.phoneNumber ?? '',
                          ownerLocation: user?.userCity ?? '',
                          ownerImage: user?.image ?? '',
                          title: _titleController.text,
                          description: _descController.text,
                          budget: double.tryParse(_priceController.text) ?? 0,
                          deadline: _selectedDeadline!,
                          createdAt: DateTime.now(),
                        );
                        context.read<TasksCubit>().postPublicTask(task);
                      }
                    } else {
                      // منطق المهمة الخاصة
                      final task = PrivateTask(
                        id: const Uuid().v4(),
                        title: _titleController.text,
                        isCompleted: false,
                        deadline: _selectedDeadline!,
                      );
                      context.read<TasksCubit>().addPrivateTask(task);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "حفظ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
