import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/upload/image_upload_cubit.dart';
import 'package:lammah/presentation/views/chat/views/chat/chat_widget.dart';
import 'package:lammah/presentation/views/chat/views/chat/image_preview_screen.dart';
import 'package:uuid/uuid.dart';

class SendResChat extends StatefulWidget {
  const SendResChat({
    super.key,
    required this.userName,
    required this.userImage,
    required this.uid,
  });

  final String userName;
  final String userImage;
  final String uid;

  @override
  State<SendResChat> createState() => _SendResChatState();
}

class _SendResChatState extends State<SendResChat> {
  final TextEditingController control = TextEditingController();

  @override
  void dispose() {
    control.dispose();
    super.dispose();
  }

  String chatRoomId() {
    List<String> userIds = [FirebaseAuth.instance.currentUser!.uid, widget.uid];
    userIds.sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUserInfo;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.userImage),
            ),
            const SizedBox(width: 10),
            Text(widget.userName),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.video_camera_back,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.gamepad,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.phone,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chat')
                    .doc(chatRoomId())
                    .collection('message')
                    .orderBy('date', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No messages yet.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> message =
                          snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                      String currentUser =
                          FirebaseAuth.instance.currentUser!.uid;
                      String senderId =
                          message['senderId'] ?? message['userId'] ?? '';
                      print('message user id $senderId');
                      return currentUser == senderId
                          ? ChatWidget(message: message, isFriend: false)
                          : ChatWidget(message: message, isFriend: true);
                    },
                  );
                },
              ),
            ),
            TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
              ),
              controller: control,
              decoration: InputDecoration(
                prefix: IconButton(
                  onPressed: () async {
                    var auth = context.read<ImageUploadCubit>();
                    final messenger = ScaffoldMessenger.of(context);
                    var nav = Navigator.of(context);

                    final user = context.read<AuthCubit>().currentUserInfo;
                    // 1. اختيار عدة صور
                    List<XFile> selectedImages = await auth
                        .pickMultipleImages();

                    if (selectedImages.isNotEmpty && mounted) {
                      // 2. الانتقال إلى شاشة المعاينة وتمرير الصور ووظيفة الإرسال
                      nav.push(
                        MaterialPageRoute(
                          builder: (context) => ImagePreviewScreen(
                            images: selectedImages,
                            onSend: (imagesToSend, caption) async {
                              try {
                                // 3. رفع الصور إلى Storage
                                List<String> imageUrls = await auth
                                    .uploadMultipleImagesAndGetUrls(
                                      imagesToSend,
                                    );

                                // 4. إرسال الرسالة إلى Firestore
                                final uuid = const Uuid().v4();

                                // التأكد من أن chatRoom document موجود
                                await FirebaseFirestore.instance
                                    .collection('chat')
                                    .doc(chatRoomId())
                                    .set(
                                      {
                                        'senderName': user?.name ?? '',
                                        'senderImage': user?.image ?? '',
                                        'senderId': user?.userId ?? '',
                                        'receiverName': widget.userName,
                                        'receiverImage': widget.userImage,
                                        'receiverId': widget.uid,
                                        'partial': [
                                          user?.userId ?? '',
                                          widget.uid,
                                        ],
                                        'chatRoomId': chatRoomId(),
                                        'date': Timestamp.now(),
                                      },
                                      SetOptions(merge: true),
                                    ); // استخدام merge لتجنب الكتابة فوق البيانات

                                await FirebaseFirestore.instance
                                    .collection('chat')
                                    .doc(chatRoomId())
                                    .collection('message')
                                    .doc(uuid)
                                    .set({
                                      'type': 'image', // نوع الرسالة
                                      'senderId': user?.userId ?? '',
                                      'date': Timestamp.now(),
                                      'imageUrls':
                                          imageUrls, // قائمة روابط الصور
                                      'caption': caption, // الشرح المكتوب
                                      'messageId': uuid,
                                    });

                                // 5. العودة من شاشة المعاينة
                                if (mounted) {
                                  nav.pop();
                                }
                              } catch (e) {
                                if (mounted) {
                                  nav.pop(); // إغلاق شاشة المعاينة في حال حدوث خطأ
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('فشل إرسال الصور: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.image,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                suffix: IconButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (control.text.trim().isNotEmpty) {
                      final uuid = const Uuid().v4();
                      try {
                        await FirebaseFirestore.instance
                            .collection('chat')
                            .doc(chatRoomId())
                            .set({
                              'senderName': user?.name ?? '',
                              'senderImage': user?.image ?? '',
                              'senderId': user?.userId ?? '',
                              'receiverName': widget.userName,
                              'receiverImage': widget.userImage,
                              'receiverId': widget.uid,
                              'partial': [user?.userId ?? '', widget.uid],
                              'chatRoomId': chatRoomId(),
                              'date': Timestamp.now(),
                            });

                        await FirebaseFirestore.instance
                            .collection('chat')
                            .doc(chatRoomId())
                            .collection('message')
                            .doc(uuid)
                            .set({
                              'message': control.text,
                              'userId': user?.userId ?? '',
                              'date': Timestamp.now(),
                              'image': '',
                              'messageId': uuid,
                            });
                        control.clear();
                      } catch (e) {
                        if (!mounted) {
                          return;
                        }

                        messenger.showSnackBar(
                          SnackBar(content: Text('Failed to send message: $e')),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                border: const OutlineInputBorder(),
                hintText: 'اكتب رسالتك هنا',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
