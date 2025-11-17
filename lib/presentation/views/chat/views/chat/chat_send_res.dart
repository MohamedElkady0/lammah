import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lammah/core/function/send_call_notification.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/upload/upload_cubit.dart';
import 'package:lammah/domian/upload/upload_state.dart';
import 'package:lammah/presentation/views/chat/views/chat/call_screen.dart';
import 'package:lammah/presentation/views/chat/views/chat/chat_widget.dart';
import 'package:lammah/presentation/views/chat/views/chat/image_preview_screen.dart';
import 'package:lammah/presentation/views/game/game_lobby_screen.dart';
// import 'package:lammah/presentation/views/game/game_screen.dart';
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
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // أضف هذا المستمع. سيقوم بتحديث الواجهة مع كل حرف تكتبه
    control.addListener(() {
      setState(() {});
    });
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() {
    final currentUser = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('chat').doc(chatRoomId()).update({
      'unreadCount.$currentUser': 0,
    });
  }

  @override
  void dispose() {
    // لا تنس إزالة المستمع لتجنب تسرب الذاكرة
    control.removeListener(() {
      setState(() {});
    });
    control.dispose();
    scrollController.dispose();
    super.dispose();
  }

  String chatRoomId() {
    List<String> userIds = [FirebaseAuth.instance.currentUser!.uid, widget.uid];
    userIds.sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> message) {
    final String messageId = message['messageId'];
    final String currentText = message['message'];
    final TextEditingController editController = TextEditingController(
      text: currentText,
    );

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('تعديل الرسالة'),
          content: TextField(
            controller: editController,
            autofocus: true,
            maxLines: null, // للسماح بتعدد الأسطر
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text('حفظ'),
              onPressed: () {
                final newText = editController.text.trim();
                if (newText.isNotEmpty) {
                  // تحديث الرسالة في Firestore وإضافة علامة التعديل
                  FirebaseFirestore.instance
                      .collection('chat')
                      .doc(chatRoomId())
                      .collection('message')
                      .doc(messageId)
                      .update({
                        'message': newText,
                        'isEdited': true, // حقل جديد لتتبع التعديل
                      });
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showActionsDialog(
    BuildContext context,
    Map<String, dynamic> message,
    bool isCurrentUserMessage,
  ) {
    // استخراج البيانات المهمة من الرسالة
    final String messageId = message['messageId'];
    final String messageType =
        message['type'] ?? 'text'; // افترض 'text' للرسائل القديمة

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        // بناء قائمة الأزرار ديناميكياً
        List<Widget> actions = [];

        // 1. إضافة زر "تعديل" فقط إذا كانت رسالة نصية ومن المستخدم الحالي
        if (isCurrentUserMessage &&
            (messageType == 'text' || messageType == '')) {
          actions.add(
            TextButton(
              child: const Text('تعديل'),
              onPressed: () {
                Navigator.of(ctx).pop(); // إغلاق قائمة الخيارات
                _showEditDialog(context, message); // فتح قائمة التعديل
              },
            ),
          );
        }

        // 2. إضافة زر "حذف" دائماً (يمكنك تعديل هذا الشرط إذا أردت)
        actions.add(
          TextButton(
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // حذف الرسالة
              FirebaseFirestore.instance
                  .collection('chat')
                  .doc(chatRoomId())
                  .collection('message')
                  .doc(messageId)
                  .delete();
              Navigator.of(ctx).pop(); // إغلاق القائمة
            },
          ),
        );

        return AlertDialog(title: const Text('اختر إجراء'), actions: actions);
      },
    );
  }

  _sendImage() async {
    var auth = context.read<UploadCubit>();
    final messenger = ScaffoldMessenger.of(context);
    var nav = Navigator.of(context);

    final user = context.read<AuthCubit>().currentUserInfo;
    // 1. اختيار عدة صور
    List<XFile> selectedImages = await auth.pickMultipleImages();

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
                    .uploadMultipleImagesAndGetUrls(imagesToSend);

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
                        'partial': [user?.userId ?? '', widget.uid],
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
                      'imageUrls': imageUrls, // قائمة روابط الصور
                      'caption': caption, // الشرح المكتوب
                      'messageId': uuid,
                    });
                // تحديث مستند المحادثة الرئيسي
                FirebaseFirestore.instance
                    .collection('chat')
                    .doc(chatRoomId())
                    .update({
                      'lastMessageImage': imageUrls, // أو وصف للملف
                      'date': Timestamp.now(),
                      'unreadCount.${widget.uid}': FieldValue.increment(
                        1,
                      ), // زيادة العداد للمستقبل
                    });
                await notifiMessage('Image', imageUrls.first);
                // 5. العودة من شاشة المعاينة
                if (mounted) {
                  nav.pop();
                }
              } catch (e) {
                if (mounted) {
                  nav.pop(); // إغلاق شاشة المعاينة في حال حدوث خطأ
                  messenger.showSnackBar(
                    SnackBar(content: Text('فشل إرسال الصور: $e')),
                  );
                }
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _sendVideo() async {
    final ImagePicker picker = ImagePicker();
    // اختيار فيديو من المعرض
    final auth = context.read<AuthCubit>();
    final XFile? videoFile = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (videoFile != null) {
      // يمكنك عرض شاشة معاينة مشابهة للصور إذا أردت

      // 1. رفع الفيديو إلى Storage
      final fileId = const Uuid().v4();
      final ref = FirebaseStorage.instance
          .ref()
          .child('video_messages')
          .child('$fileId.mp4');
      // إظهار مؤشر تحميل...
      await ref.putFile(File(videoFile.path));
      final videoUrl = await ref.getDownloadURL();

      // 2. إرسال الرسالة إلى Firestore
      final user = auth.currentUserInfo;
      final messageId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('chat')
          .doc(chatRoomId())
          .collection('message')
          .doc(messageId)
          .set({
            'type': 'video', // نوع الرسالة
            'senderId': user?.userId ?? '',
            'date': Timestamp.now(),
            'videoUrl': videoUrl,
            'fileName': videoFile.name, // حفظ اسم الملف
            'messageId': messageId,
          });
      // تحديث مستند المحادثة الرئيسي
      FirebaseFirestore.instance.collection('chat').doc(chatRoomId()).update({
        'lastMessageVideo': videoUrl, // أو وصف للملف
        'date': Timestamp.now(),
        'unreadCount.${widget.uid}': FieldValue.increment(
          1,
        ), // زيادة العداد للمستقبل
      });
      await notifiMessage('Video', videoUrl);
    }
  }

  // داخل _SendResChatState
  Future<void> _sendFile() async {
    // اختيار أي نوع من الملفات
    final auth = context.read<AuthCubit>();
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // 1. رفع الملف إلى Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('file_messages')
          .child(fileName);
      await ref.putFile(file);
      final fileUrl = await ref.getDownloadURL();

      // 2. إرسال الرسالة إلى Firestore
      final user = auth.currentUserInfo;
      final messageId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('chat')
          .doc(chatRoomId())
          .collection('message')
          .doc(messageId)
          .set({
            'type': 'file',
            'senderId': user?.userId ?? '',
            'date': Timestamp.now(),
            'fileUrl': fileUrl,
            'fileName': fileName,
            'messageId': messageId,
          });
      // تحديث مستند المحادثة الرئيسي
      FirebaseFirestore.instance.collection('chat').doc(chatRoomId()).update({
        'lastMessageFile': fileUrl, // أو وصف للملف
        'date': Timestamp.now(),
        'unreadCount.${widget.uid}': FieldValue.increment(
          1,
        ), // زيادة العداد للمستقبل
      });
      await notifiMessage('File', fileUrl);
    }
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('صورة'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sendImage(); // دالتك الحالية لإرسال الصور
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('فيديو'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sendVideo();
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text('ملف'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sendFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  notifiMessage(String typeMessage, String message) async {
    final user = context.read<AuthCubit>().currentUserInfo;

    // 1. احصل على بيانات المستقبل (FCM Token)
    final receiverDoc = await FirebaseFirestore.instance
        .collection(AuthString.fSUsers)
        .doc(widget.uid)
        .get();
    final receiverFcmToken = receiverDoc.data()?['fcmToken'];

    if (receiverFcmToken != null) {
      // 3. استدعِ الدالة السحابية
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'sendNotification',
      );
      await callable.call(<String, dynamic>{
        'receiverFcmToken': receiverFcmToken,
        'type': typeMessage, // نوع الإشعار
        'senderName': user?.name ?? 'مستخدم جديد',
        'senderImage': user?.image ?? '', // رابط الصورة الشخصية للمرسل
        'messageContent': message, // محتوى الرسالة
        'chatRoomId': chatRoomId(),
        'senderId': user?.userId ?? '',
      });
    }
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
            onPressed: () async {
              var nav = Navigator.of(context);
              final caller = context.read<AuthCubit>().currentUserInfo;
              final receiverDoc = await FirebaseFirestore.instance
                  .collection(AuthString.fSUsers)
                  .doc(widget.uid)
                  .get();
              final receiverData = receiverDoc.data() as Map<String, dynamic>;
              final receiverFcmToken = receiverData['fcmToken'];

              if (caller != null && receiverFcmToken != null) {
                // 2. إنشاء مستند المكالمة
                final callDoc = FirebaseFirestore.instance
                    .collection('calls')
                    .doc();
                final callId = callDoc.id;
                final channelName =
                    callId; // استخدام ID المستند كاسم للقناة لضمان التفرد

                await callDoc.set({
                  'callerId': caller.userId,
                  'callerName': caller.name,
                  'callerImage': caller.image,
                  'receiverId': widget.uid,
                  'receiverName': widget.userName,
                  'receiverImage': widget.userImage,
                  'channelName': channelName,
                  'isVideoCall': true, // أو false للمكالمة الصوتية
                  'status': 'ringing', // (ringing, accepted, rejected, missed)
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // 3. إرسال إشعار FCM (هذا يتطلب Cloud Function للأمان)
                // هذا مثال مبسط. في الإنتاج، يجب أن يتم هذا عبر Cloud Function
                // لإرسال الإشعار إلى receiverFcmToken مع بيانات المكالمة (callId)
                // Placeholder for sending FCM notification
                sendNotification(
                  receiverFcmToken,
                  callId,
                  caller.name ?? "Someone",
                  '',
                  true,
                );
                // مكالمة فيديو
                nav.push(
                  MaterialPageRoute(
                    builder: (context) => CallScreen(
                      appId:
                          "5d7dd5867101474e8207d864bf39fc94", // ضع الـ App ID الخاص بك هنا
                      channelName:
                          chatRoomId(), // استخدام chatRoomId كاسم للقناة
                      isVideoCall: true,
                    ),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.video_camera_back,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          IconButton(
            onPressed: () async {
              var nav = Navigator.of(context);
              final auth = context.read<AuthCubit>();
              final currentUser = auth.currentUserInfo;
              // final otherUserUid = widget.uid; // uid للطرف الآخر

              if (currentUser != null) {
                // // إنشاء مستند جديد للعبة
                // final gameSession = await FirebaseFirestore.instance
                //     .collection('games')
                //     .add({
                //       'players': [currentUser.userId, otherUserUid],
                //       'board': List.generate(9, (_) => ""), // لوحة فارغة
                //       'currentPlayerUid': currentUser.userId, // أنت تبدأ
                //       'winner': "",
                //       'status': "playing",
                //     });

                // الانتقال إلى شاشة اللعبة
                nav.push(
                  MaterialPageRoute(
                    builder: (context) => GameLobbyScreen(
                      chatRoomId: chatRoomId(),
                      currentUserUid: FirebaseAuth.instance.currentUser!.uid,
                      otherUserUid: widget.uid,
                    ),
                  ),
                );
              }
            },
            icon: Icon(
              Icons.gamepad,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              // مكالمة صوتية
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    appId:
                        "5d7dd5867101474e8207d864bf39fc94", // ضع الـ App ID الخاص بك هنا
                    channelName: chatRoomId(),
                    isVideoCall: false,
                  ),
                ),
              );
            },
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
                  // هذا الكود يضمن أن التمرير يحدث بعد بناء الواجهة
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (scrollController.hasClients) {
                      scrollController.jumpTo(
                        scrollController.position.maxScrollExtent,
                      );
                    }
                  });
                  return ListView.builder(
                    // reverse: true,
                    controller: scrollController,
                    // shrinkWrap: true,
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

                      bool isCurrentUserMessage = currentUser == senderId;

                      Widget messageWidget = isCurrentUserMessage
                          ? ChatWidget(message: message, isFriend: false)
                          : ChatWidget(message: message, isFriend: true);

                      return GestureDetector(
                        onLongPress: () {
                          _showActionsDialog(
                            context,
                            message,
                            isCurrentUserMessage,
                          );
                        },
                        child: messageWidget,
                      );
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
                    _showAttachmentMenu(context);
                  },
                  icon: Icon(
                    Icons.attach_file,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                suffix: control.text.trim().isEmpty
                    ? BlocBuilder<UploadCubit, UploadState>(
                        builder: (context, state) {
                          final upload = context.read<UploadCubit>();
                          final isRecording = upload.isRecording;

                          return GestureDetector(
                            onLongPress: () {
                              upload.startRecording();
                            },
                            onLongPressEnd: (details) {
                              final user = context
                                  .read<AuthCubit>()
                                  .currentUserInfo;
                              if (user != null) {
                                Map<String, dynamic> userInfoMap = {
                                  'userId': user.userId,
                                };
                                upload.stopRecordingAndSend(
                                  chatRoomId: chatRoomId(),
                                  currentUserInfo: userInfoMap,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Icon(
                                isRecording
                                    ? Icons.stop_circle_outlined
                                    : Icons.mic,
                                color: isRecording
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.onPrimary,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      )
                    : IconButton(
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
                              // تحديث مستند المحادثة الرئيسي
                              FirebaseFirestore.instance
                                  .collection('chat')
                                  .doc(chatRoomId())
                                  .update({
                                    'lastMessage': control.text, // أو وصف للملف
                                    'date': Timestamp.now(),
                                    'unreadCount.${widget.uid}':
                                        FieldValue.increment(
                                          1,
                                        ), // زيادة العداد للمستقبل
                                  });
                              await notifiMessage('Text', control.text);
                              control.clear();
                            } catch (e) {
                              if (!mounted) {
                                return;
                              }

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Failed to send message: $e'),
                                ),
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
