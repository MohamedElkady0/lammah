import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/domian/chat/chat_cubit.dart'; // تأكد من المسار

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedMemberIds = [];

  // لم نعد بحاجة لـ _isLoading هنا لأن الـ Cubit يدير الحالة

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is NavChat) {
          // تم الإنشاء بنجاح
          // ملاحظة: بما أن حالة NavChat الحالية لا تحمل ID المجموعة، سنقوم بإغلاق الشاشة
          // والعودة لقائمة المحادثات حيث ستظهر المجموعة الجديدة هناك.
          Navigator.pop(context);
        }
        if (state is ChatFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is ChatLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('إنشاء مجموعة جديدة')),
          body: Column(
            children: [
              // حقل لاسم المجموعة
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _groupNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المجموعة',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isLoading, // تعطيل الكتابة أثناء التحميل
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "اختر الأعضاء:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // قائمة لاختيار الأصدقاء
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    final List<dynamic> friendIds = userData?['friends'] ?? [];

                    if (friendIds.isEmpty) {
                      return const Center(
                        child: Text("لا يوجد أصدقاء لإضافتهم"),
                      );
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where(FieldPath.documentId, whereIn: friendIds)
                          .snapshots(),
                      builder: (context, friendsSnapshot) {
                        if (!friendsSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView.builder(
                          itemCount: friendsSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final friendDoc = friendsSnapshot.data!.docs[index];
                            final friendUid = friendDoc.id;
                            final isSelected = _selectedMemberIds.contains(
                              friendUid,
                            );

                            return CheckboxListTile(
                              title: Text(friendDoc['name'] ?? 'مستخدم'),
                              secondary: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  friendDoc['image'] ?? '',
                                ),
                              ),
                              value: isSelected,
                              onChanged: isLoading
                                  ? null
                                  : (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedMemberIds.add(friendUid);
                                        } else {
                                          _selectedMemberIds.remove(friendUid);
                                        }
                                      });
                                    },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: isLoading
                ? null
                : () {
                    // استدعاء دالة الإنشاء
                    _createGroup(context);
                  },
            backgroundColor: isLoading
                ? Colors.grey
                : Theme.of(context).primaryColor,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.check),
          ),
        );
      },
    );
  }

  void _createGroup(BuildContext context) {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة اسم المجموعة')),
      );
      return;
    }
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار عضو واحد على الأقل')),
      );
      return;
    }

    // استدعاء الـ Cubit
    context.read<ChatCubit>().createGroup(
      groupName: _groupNameController.text,
      selectedMemberIds: _selectedMemberIds,
    );
  }
}
