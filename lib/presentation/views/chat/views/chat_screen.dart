import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/domian/chat/chat_cubit.dart'; // تأكد من المسار
import 'package:lammah/presentation/views/chat/views/chat_send_res.dart';
import 'package:lammah/presentation/views/chat/views/friends.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  // القائمة المنبثقة
  // تعديل الدالة لتقبل otherUserId (يمكن أن يكون null في حالة الجروبات)
  Widget popButton(
    BuildContext context,
    String docId,
    String collectionPath,
    String currentUserId,
    String? otherUserId, // <--- معامل جديد
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // هنا نستخدم الـ Cubit، لذا سيختفي التحذير
        final cubit = context.read<ChatCubit>();

        final docRef = FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(docId);

        if (value == 'delete') {
          docRef.update({'deletedBy.$currentUserId': true});
        }

        // تفعيل منطق الحظر
        if (value == 'block' &&
            collectionPath == 'chat' &&
            otherUserId != null) {
          // استدعاء دالة الحظر من الـ Cubit
          cubit.blockUser(otherUserId);

          // اختياري: إظهار رسالة تأكيد
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم حظر المستخدم')));
        }

        if (value == 'markRead') {
          docRef.update({'unreadCount.$currentUserId': 0});
        }
        if (value == 'MarkUnread') {
          docRef.update({'unreadCount.$currentUserId': 1});
        }
      },
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          const PopupMenuItem(value: 'delete', child: Text('حذف المحادثة')),
          // إظهار خيار الحظر فقط في المحادثات الفردية
          if (collectionPath == 'chat')
            const PopupMenuItem(value: 'block', child: Text('حظر المستخدم')),
          const PopupMenuItem(value: 'markRead', child: Text('تمييز كمقروء')),
          const PopupMenuItem(
            value: 'MarkUnread',
            child: Text('تمييز كغير مقروء'),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();

    // 1. استعلام المحادثات الفردية
    final chatsStream = FirebaseFirestore.instance
        .collection('chat')
        .where('partial', arrayContains: currentUserUid)
        .orderBy('date', descending: true)
        .snapshots();

    // 2. استعلام المجموعات
    final groupsStream = FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: currentUserUid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();

    return Container(
      color: Theme.of(context).colorScheme.primary,

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40), // Spacing
                Text(
                  'المحادثات',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: Icon(
                    Icons.people,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FriendsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<QuerySnapshot>>(
              stream: StreamZip([chatsStream, groupsStream]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData ||
                    (snapshot.data![0].docs.isEmpty &&
                        snapshot.data![1].docs.isEmpty)) {
                  return Center(
                    child: Text(
                      'لا توجد محادثات بعد.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  );
                }

                // 4. دمج وتصفية القائمتين
                final chatDocs = snapshot.data![0].docs;
                final groupDocs = snapshot.data![1].docs;
                final allConversations = [...chatDocs, ...groupDocs];

                // تصفية المحادثات المحذوفة من قبلي
                final visibleConversations = allConversations.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final deletedBy = data['deletedBy'] as Map<String, dynamic>?;
                  return deletedBy == null || deletedBy[currentUserUid] != true;
                }).toList();

                if (visibleConversations.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد محادثات.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  );
                }

                // 5. الترتيب اليدوي
                visibleConversations.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  Timestamp timeA =
                      dataA['date'] ??
                      dataA['lastMessageTimestamp'] ??
                      Timestamp.now();
                  Timestamp timeB =
                      dataB['date'] ??
                      dataB['lastMessageTimestamp'] ??
                      Timestamp.now();

                  return timeB.compareTo(timeA);
                });

                return ListView.builder(
                  itemCount: visibleConversations.length,
                  itemBuilder: (context, index) {
                    final doc = visibleConversations[index];
                    final chatMap = doc.data() as Map<String, dynamic>;
                    // استخراج بيانات آخر رسالة للتحقق قبل استدعاء الدالة
                    String lastStatus = chatMap['lastMessageStatus'] ?? '';
                    // في بعض الأحيان يكون senderId هو مرسل آخر رسالة في مستند المحادثة الرئيسي
                    // تأكد من أنك تقوم بتحديث هذا الحقل عند إرسال رسالة جديدة
                    String lastSenderId =
                        chatMap['lastMessageSenderId'] ??
                        chatMap['senderId'] ??
                        '';

                    // متغيرات العرض
                    String name = '';
                    String image = '';
                    String targetUid = '';
                    bool isGroup = false;
                    String lastMessage = '';

                    // تحديد النوع (جروب أم فردي)
                    if (chatMap.containsKey('groupName')) {
                      isGroup = true;
                      name = chatMap['groupName'] ?? 'مجموعة';
                      image = chatMap['groupImage'] ?? '';
                      lastMessage = chatMap['lastMessage'] ?? '';
                    } else {
                      isGroup = false;
                      final bool isMeSender =
                          currentUserUid == chatMap['senderId'];
                      name = isMeSender
                          ? (chatMap['receiverName'] ?? 'مستخدم')
                          : (chatMap['senderName'] ?? 'مستخدم');
                      image = isMeSender
                          ? (chatMap['receiverImage'] ?? '')
                          : (chatMap['senderImage'] ?? '');
                      targetUid = isMeSender
                          ? (chatMap['receiverId'] ?? '')
                          : (chatMap['senderId'] ?? '');
                      lastMessage =
                          chatMap['lastMessage'] ?? chatMap['message'] ?? '';
                    }

                    // منطق "تم التسليم" (Delivered)
                    // يتم استدعاؤه هنا لضمان تحديث الحالة بمجرد ظهور المحادثة في القائمة
                    if (!isGroup &&
                        lastSenderId != currentUserUid &&
                        lastStatus == 'sent') {
                      chatCubit.markMessagesAsDelivered(
                        chatId: doc.id,
                        isGroupChat: isGroup,
                      );
                    }

                    // الرسائل غير المقروءة
                    final unreadCountData =
                        chatMap['unreadCount'] as Map<String, dynamic>?;
                    final int myUnreadCount =
                        unreadCountData?[currentUserUid] ?? 0;
                    final bool hasUnreadMessages = myUnreadCount > 0;

                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SendResChat(
                                userName: name,
                                userImage: image,
                                uid: isGroup ? '' : targetUid,
                                isGroupChat: isGroup,
                                chatId: doc.id,
                              );
                            },
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: image.isNotEmpty
                            ? NetworkImage(image)
                            : null,
                        backgroundColor: Colors.grey.shade300,
                        child: image.isEmpty
                            ? Icon(
                                isGroup ? Icons.groups : Icons.person,
                                color: Colors.grey.shade700,
                              )
                            : null,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: hasUnreadMessages
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        lastMessage,
                        style: TextStyle(
                          color: hasUnreadMessages
                              ? Colors.white
                              : Colors.white70,
                          fontWeight: hasUnreadMessages
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (hasUnreadMessages)
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                myUnreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          // زر الخيارات (PopUp)
                          SizedBox(
                            height: 30,
                            width: 30,
                            child: popButton(
                              context,
                              doc.id,
                              isGroup ? 'groups' : 'chat',
                              currentUserUid,
                              isGroup
                                  ? null
                                  : targetUid, // <--- تمرير معرف الطرف الآخر
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
