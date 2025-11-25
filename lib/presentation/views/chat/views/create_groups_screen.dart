import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/chat/views/chat_send_res.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedMemberIds = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء مجموعة جديدة')),
      body: Column(
        children: [
          // حقل لاسم المجموعة والصورة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(labelText: 'اسم المجموعة'),
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
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                final List<dynamic> friendIds = userData?['friends'] ?? [];

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where(FieldPath.documentId, whereIn: friendIds)
                      .snapshots(),
                  builder: (context, friendsSnapshot) {
                    if (!friendsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
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
                          title: Text(friendDoc['name']),
                          value: isSelected,
                          onChanged: (bool? value) {
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
        onPressed: _isLoading ? null : _createGroup,
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Icon(Icons.check),
      ),
    );
  }

  void _createGroup() async {
    if (_groupNameController.text.trim().isEmpty ||
        _selectedMemberIds.isEmpty) {
      // عرض رسالة خطأ
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final members = [currentUserUid, ..._selectedMemberIds];

    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .add({
            'groupName': _groupNameController.text.trim(),
            'groupImage': '', // يمكنك إضافة منطق رفع صورة
            'createdBy': currentUserUid,
            'createdAt': Timestamp.now(),
            'admins': [currentUserUid],
            'members': members,
            'lastMessage': 'تم إنشاء المجموعة.',
            'lastMessageTimestamp': Timestamp.now(),
            'lastMessageSenderName': 'النظام',
            'unreadCount': {for (var member in members) member: 0},
          });

      if (!mounted) return;

      // استخدام groupDoc.id للانتقال للمحادثة فوراً
      // نستخدم pushReplacement لإغلاق شاشة الإنشاء وفتح المحادثة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SendResChat(
            userName: _groupNameController.text.trim(),
            userImage: '', // أو الصورة التي تم رفعها
            uid: '', // في المجموعات لا نحتاج لـ uid فردي
            isGroupChat: true, // <--- تفعيل وضع المجموعة
            chatId: groupDoc.id, // <--- هنا استخدمنا المتغير (حل المشكلة)
          ),
        ),
      );
    } catch (e) {
      // معالجة الخطأ
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
