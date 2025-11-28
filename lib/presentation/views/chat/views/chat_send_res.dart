import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lammah/core/utils/chat_string.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/chat/chat_cubit.dart'; // تأكد من المسار
import 'package:lammah/presentation/views/chat/views/call_screen.dart';
import 'package:lammah/presentation/views/chat/widget/chat_widget.dart';
import 'package:lammah/presentation/views/chat/views/image_preview_screen.dart';
import 'package:lammah/presentation/views/game/game_lobby_screen.dart';

class SendResChat extends StatefulWidget {
  const SendResChat({
    super.key,
    required this.userName,
    required this.userImage,
    required this.uid,
    required this.isGroupChat,
    required this.chatId,
  });

  final String userName;
  final String userImage;
  final String uid;
  final bool isGroupChat;
  final String chatId;

  @override
  State<SendResChat> createState() => _SendResChatState();
}

class _SendResChatState extends State<SendResChat> {
  final TextEditingController control = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    control.addListener(() {
      setState(() {});
    });

    // جعل الرسائل مقروءة عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().markMessagesAsSeen(
        chatId: widget.chatId,
        isGroupChat: widget.isGroupChat,
      );
    });
  }

  @override
  void dispose() {
    control.dispose();
    scrollController.dispose();
    // إيقاف التسجيل إذا خرج المستخدم أثناء التسجيل (اختياري، لكن الـ Cubit لديه close)
    super.dispose();
  }

  // القائمة المنبثقة للمرفقات
  void _showAttachmentMenu(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    var nav = Navigator.of(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('صورة'),
                onTap: () async {
                  Navigator.of(context).pop();
                  // اختيار الصور
                  final picker = ImagePicker();
                  final List<XFile> images = await picker.pickMultiImage();
                  if (images.isNotEmpty && mounted) {
                    // الانتقال للمعاينة
                    nav.push(
                      MaterialPageRoute(
                        builder: (_) => ImagePreviewScreen(
                          images: images,
                          onSend: (finalImages, caption) {
                            cubit.sendImage(
                              isGroupChat: widget.isGroupChat,
                              chatId: widget.chatId,
                              uid: widget.uid,
                              userName: widget.userName,
                              userImage: widget.userImage,
                              preSelectedImages: finalImages,
                              caption: caption,
                            );
                            Navigator.pop(context); // إغلاق المعاينة
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('فيديو'),
                onTap: () {
                  Navigator.of(context).pop();
                  cubit.sendVideo(
                    uid: widget.uid,
                    isGroupChat: widget.isGroupChat,
                    chatId: widget.chatId,
                    userName: widget.userName,
                    userImage: widget.userImage,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('ملف'),
                onTap: () {
                  Navigator.of(context).pop();
                  cubit.sendFile(
                    uid: widget.uid,
                    isGroupChat: widget.isGroupChat,
                    chatId: widget.chatId,
                    userName: widget.userName,
                    userImage: widget.userImage,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUserInfo;
    final isFriend = user?.friends?.contains(widget.uid) ?? false;
    final chatCubit = context.read<ChatCubit>();

    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatSuccess) {
          control.clear(); // مسح الحقل عند نجاح الإرسال
        }
        if (state is ChatFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
        if (state is NavChatCall) {
          // الانتقال لشاشة الاتصال عند بدء المكالمة بنجاح
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallScreen(
                appId: ChatString.appIdVideo,
                channelName: widget.chatId.isEmpty
                    ? chatCubit.chatRoomId(widget.uid)
                    : widget.chatId, // استخدام ID المكالمة
                isVideoCall: true,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // التحقق من حالة التسجيل لتغيير الأيقونة
        bool isRecording = chatCubit.isRecording;
        if (state is RecordingStateChanged) {
          isRecording = state.isRecording;
        }

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
                Expanded(
                  child: Text(widget.userName, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            actions: [
              // زر مكالمة الفيديو
              IconButton(
                onPressed: () {
                  chatCubit.sendVideoCall(
                    uid: widget.uid,
                    userName: widget.userName,
                    userImage: widget.userImage,
                  );
                },
                icon: Icon(
                  Icons.video_camera_back,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              // زر اللعبة
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameLobbyScreen(
                        chatRoomId: widget.chatId,
                        currentUserUid: FirebaseAuth.instance.currentUser!.uid,
                        otherUserUid: widget.uid,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.gamepad,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              // زر إضافة صديق
              if (!isFriend && !widget.isGroupChat)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    chatCubit.addFriends(widget.uid);
                  },
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // قائمة الرسائل
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: chatCubit.getMessageStream(
                      isGroupChat: widget.isGroupChat,
                      chatId: widget.chatId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('ابدأ المحادثة الآن!'));
                      }

                      // تحديث "Seen" عند وصول رسائل جديدة وأنا في الشاشة
                      if (snapshot.hasData) {
                        // استخدام addPostFrameCallback لتجنب البناء أثناء البناء
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // استدعاء الدالة فقط إذا كانت هناك رسائل غير مقروءة (يمكن تحسين المنطق داخل الكيوبت)
                          chatCubit.markMessagesAsSeen(
                            chatId: widget.chatId,
                            isGroupChat: widget.isGroupChat,
                          );
                        });
                      }

                      // النزول لأسفل القائمة
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (scrollController.hasClients) {
                          scrollController.jumpTo(
                            scrollController.position.maxScrollExtent,
                          );
                        }
                      });

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index];
                          Map<String, dynamic> message =
                              doc.data() as Map<String, dynamic>;
                          String currentUser =
                              FirebaseAuth.instance.currentUser!.uid;
                          String senderId =
                              message['senderId'] ?? message['userId'] ?? '';

                          bool isMe = currentUser == senderId;

                          // استخدام ChatWidget الجديد (يدعم التعديل والحذف داخلياً)
                          return ChatWidget(
                            message: message,
                            isFriend: !isMe,
                            isGroupChat: widget.isGroupChat,
                            chatId: widget.chatId,
                          );
                        },
                      );
                    },
                  ),
                ),

                // حقل الإدخال
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    controller: control,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                        onPressed: () => _showAttachmentMenu(context),
                        icon: Icon(
                          Icons.attach_file,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      suffixIcon: control.text.trim().isEmpty
                          ? GestureDetector(
                              onLongPress: () {
                                chatCubit.startRecording();
                              },
                              onLongPressUp: () {
                                chatCubit.stopRecordingAndSend(
                                  chatRoomId: widget.chatId,
                                  receiverId: widget.uid,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
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
                            )
                          : IconButton(
                              onPressed: () {
                                chatCubit.sendMessageText(
                                  isGroupChat: widget.isGroupChat,
                                  chatId: widget.chatId,
                                  textMessage: control.text,
                                  receiverId: widget.uid,
                                  receiverImage: widget.userImage,
                                  receiverName: widget.userName,
                                );
                              },
                              icon: Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                      hintText: isRecording
                          ? 'جاري التسجيل...'
                          : 'اكتب رسالة...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: isRecording
                          ? Colors.red[100]
                          : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
