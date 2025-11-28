import 'package:async/async.dart'; // <--- هام جداً: استيراد هذه المكتبة
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/chat/views/chat_send_res.dart';
import 'package:lammah/presentation/views/chat/views/friends.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // تعديل دالة القائمة المنبثقة لتقبل معرف المحادثة ونوعها
  Widget popButton(
    BuildContext context,
    String docId, // نستخدم ID المستند مباشرة
    String collectionPath, // نعرف هل هو chat أم groups
    String currentUserId,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        final docRef = FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(docId);

        if (value == 'delete') {
          docRef.update({'deletedBy.$currentUserId': true});
        }
        // الحظر يعمل فقط مع المستخدمين وليس الجروبات
        if (value == 'block' && collectionPath == 'chat') {
          // (منطق الحظر كما هو...)
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
          const PopupMenuItem(value: 'delete', child: Text('حذف')),
          if (collectionPath == 'chat') // إخفاء الحظر في الجروبات
            const PopupMenuItem(value: 'block', child: Text('حظر')),
          const PopupMenuItem(value: 'markRead', child: Text('تمييز كمقروء')),
          const PopupMenuItem(
            value: 'MarkUnread',
            child: Text('تمييز كغير مقروء'),
          ),
        ];
      },
    );
  }

  Future<void> _markMessagesAsDelivered(String chatId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // ابحث عن الرسائل التي لم أرسلها أنا، وحالتها "sent" فقط
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat')
        .doc(chatId)
        .collection('message')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('status', isEqualTo: 'sent')
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'status': 'delivered'});
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('Chat', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FriendsScreen()),
              );
            },
          ),
        ],
      ),
      // 3. تصحيح نوع StreamBuilder ليستقبل قائمة من الـ Snapshots
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: StreamZip([chatsStream, groupsStream]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData ||
              (snapshot.data![0].docs.isEmpty &&
                  snapshot.data![1].docs.isEmpty)) {
            return const Center(child: Text('No chats available.'));
          }

          // 4. دمج القائمتين
          final chatDocs = snapshot.data![0].docs;
          final groupDocs = snapshot.data![1].docs;
          final allConversations = [...chatDocs, ...groupDocs];

          // 5. الترتيب اليدوي (لأن الترتيب يضيع عند الدمج)
          allConversations.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            // التعامل مع اختلاف أسماء حقول الوقت بين الجروب والمحادثة
            Timestamp timeA =
                dataA['date'] ??
                dataA['lastMessageTimestamp'] ??
                Timestamp.now();
            Timestamp timeB =
                dataB['date'] ??
                dataB['lastMessageTimestamp'] ??
                Timestamp.now();

            return timeB.compareTo(timeA); // تنازلي
          });

          return ListView.builder(
            itemCount: allConversations.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final doc = allConversations[index];
              final chatMap = doc.data() as Map<String, dynamic>;

              // متغيرات العرض
              String name = '';
              String image = '';
              String targetUid = ''; // للمحادثات الفردية
              bool isGroup = false;
              String lastMessage = '';

              // منطق تحديث حالة "تم التسليم"
              // إذا كانت آخر رسالة ليست مني، وحالتها "sent"، اجعلها "delivered"
              if (chatMap['lastMessageSenderId'] != currentUserUid &&
                  chatMap['lastMessageStatus'] == 'sent') {
                // تحديث المستند الرئيسي (اختياري للعرض الخارجي)
                FirebaseFirestore.instance
                    .collection('chat')
                    .doc(doc.id)
                    .update({'lastMessageStatus': 'delivered'});

                // الأهم: تحديث الرسائل داخل المجموعة الفرعية
                // هذه عملية قد تكون مكلفة إذا كانت الرسائل كثيرة، لذا نحدث فقط غير المقروءة
                // يفضل عمل دالة منفصلة لهذا الغرض
                _markMessagesAsDelivered(doc.id);
              }

              // 6. التحقق هل هو جروب أم محادثة فردية
              if (chatMap.containsKey('groupName')) {
                // --- حالة الجروب ---
                isGroup = true;
                name = chatMap['groupName'] ?? 'Unnamed Group';
                image = chatMap['groupImage'] ?? '';
                lastMessage = chatMap['lastMessage'] ?? '';
                // الجروب ليس له targetUid واحد
              } else {
                // --- حالة المحادثة الفردية ---
                isGroup = false;
                name = currentUserUid == chatMap['senderId']
                    ? chatMap['receiverName'] ?? 'Unknown'
                    : chatMap['senderName'] ?? 'Unknown';
                image = currentUserUid == chatMap['senderId']
                    ? chatMap['receiverImage'] ?? ''
                    : chatMap['senderImage'] ?? '';
                targetUid = currentUserUid == chatMap['senderId']
                    ? chatMap['receiverId'] ?? ''
                    : chatMap['senderId'] ?? '';
                lastMessage =
                    chatMap['lastMessage'] ??
                    chatMap['message'] ??
                    ''; // أحياناً تخزن كـ message
              }

              // الرسائل غير المقروءة
              final unreadCountData =
                  chatMap['unreadCount'] as Map<String, dynamic>?;
              final int myUnreadCount = unreadCountData?[currentUserUid] ?? 0;
              final bool hasUnreadMessages = myUnreadCount > 0;

              return Padding(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  onTap: () {
                    // 7. إصلاح التنقل بتمرير البارامترات المطلوبة
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SendResChat(
                            userName: name,
                            userImage: image,
                            uid: isGroup
                                ? ''
                                : targetUid, // في الجروب لا يهم الـ uid الفردي
                            isGroupChat: isGroup, // <--- تمرير نوع المحادثة
                            chatId: doc
                                .id, // <--- تمرير ID المستند (سواء كان غرفة أو جروب)
                          );
                        },
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: image.isNotEmpty
                        ? NetworkImage(image)
                        : null,
                    child: image.isEmpty
                        ? Icon(
                            isGroup ? Icons.groups : Icons.person,
                          ) // أيقونة مختلفة للجروب
                        : null,
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: hasUnreadMessages
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    lastMessage,
                    style: TextStyle(
                      color: hasUnreadMessages
                          ? Colors.white
                          : Colors.grey.shade400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: hasUnreadMessages
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            popButton(
                              context,
                              doc.id,
                              isGroup ? 'groups' : 'chat',
                              currentUserUid,
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Text(
                                myUnreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        )
                      : popButton(
                          context,
                          doc.id,
                          isGroup ? 'groups' : 'chat',
                          currentUserUid,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
