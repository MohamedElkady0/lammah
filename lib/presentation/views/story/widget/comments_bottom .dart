import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/story/story_cubit.dart'; // تأكد من المسار

class CommentsBottomSheet extends StatefulWidget {
  final String storyId;
  final String currentUserId;

  const CommentsBottomSheet({
    super.key,
    required this.storyId,
    required this.currentUserId,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var user = context.read<AuthCubit>().currentUserInfo;
    // نستخدم Padding لرفع الشاشة فوق الكيبورد
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7, // 70% من الشاشة
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E), // لون داكن مناسب للستوري
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // مقبض السحب
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "التعليقات",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24),

            // قائمة التعليقات (StreamBuilder لتحديث لحظي)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stories')
                    .doc(widget.storyId)
                    .collection('comments')
                    .orderBy('dateTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "لا توجد تعليقات، كن الأول!",
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      // ... داخل ListView.builder ...
                      var data = docs[index].data() as Map<String, dynamic>;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          // 3. عرض صورة المعلق
                          backgroundImage:
                              (data['userImage'] != null &&
                                  data['userImage'] != '')
                              ? NetworkImage(data['userImage'])
                              : null,
                          child:
                              (data['userImage'] == null ||
                                  data['userImage'] == '')
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        // 4. عرض اسم المعلق
                        title: Text(
                          data['name'] ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          data['text'] ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // حقل الكتابة
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "أضف تعليقاً...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        StoryCubit.get(context).commentOnStory(
                          storyId: widget.storyId,
                          uId: widget.currentUserId,
                          text: _controller.text,
                          name: user?.name ?? 'User',
                          userImage: user?.image ?? '',
                        );
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
