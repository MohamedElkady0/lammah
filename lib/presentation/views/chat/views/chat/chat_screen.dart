import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lammah/presentation/views/chat/views/chat/chat_send_res.dart';
import 'package:lammah/presentation/views/chat/views/friends.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // قائمة الخيارات المنبثقة
  Widget popButton(
    BuildContext context,
    Map<String, dynamic> chatMap,
    String uId,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        final chatRoomId = chatMap['chatRoomId'];
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;
        if (value == 'delete') {
          FirebaseFirestore.instance.collection('chat').doc(chatRoomId).update({
            'deletedBy.${FirebaseAuth.instance.currentUser!.uid}': true,
          });
        }
        if (value == 'block') {
          final otherUserUid = uId; // الـ uId الخاص بالمستخدم الآخر في المحادثة
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .update({
                'blockedUsers': FieldValue.arrayUnion([otherUserUid]),
              });
          // (اختياري) يمكنك أيضاً حظره من عندك (أي أنك تحظره أيضاً)
          FirebaseFirestore.instance
              .collection('users')
              .doc(otherUserUid)
              .update({
                'blockedBy': FieldValue.arrayUnion([currentUserId]),
              });
        }
        if (value == 'markRead') {
          FirebaseFirestore.instance
              .collection('chat')
              .doc(chatRoomId())
              .update({'unreadCount.$currentUserId': 0});
        }
        if (value == 'MarkUnread') {
          FirebaseFirestore.instance.collection('chat').doc(chatRoomId).update({
            'unreadCount.$currentUserId': 1, // أو أي عدد تريده
          });
        }
      },
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          const PopupMenuItem(value: 'delete', child: Text('حذف')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,

      appBar: AppBar(
        title: Row(
          children: [
            Text('Chat', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendsScreen()),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .where(
              'partial',
              arrayContains: FirebaseAuth.instance.currentUser!.uid,
            )
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              Map<String, dynamic> chatMap =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              String currentUser = FirebaseAuth.instance.currentUser!.uid;

              String name = currentUser == chatMap['senderId']
                  ? chatMap['receiverName'] ?? 'Unknown'
                  : chatMap['senderName'] ?? 'Unknown';

              String image = currentUser == chatMap['senderId']
                  ? chatMap['receiverImage'] ?? ''
                  : chatMap['senderImage'] ?? '';

              String uId = currentUser == chatMap['senderId']
                  ? chatMap['receiverId'] ?? ''
                  : chatMap['senderId'] ?? '';

              // احصل على عدد الرسائل غير المقروءة لك
              final unreadCountData =
                  chatMap['unreadCount'] as Map<String, dynamic>?;
              final int myUnreadCount = unreadCountData?[currentUser] ?? 0;
              final bool hasUnreadMessages = myUnreadCount > 0;

              return Padding(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  onLongPress: () {},
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SendResChat(
                            userName: name,
                            userImage: image,
                            uid: uId,
                          );
                        },
                      ),
                    );
                  },
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
                    chatMap['lastMessage'], // عرض آخر رسالة
                    style: TextStyle(
                      color: hasUnreadMessages
                          ? Colors.white
                          : Colors.grey.shade400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: image.isNotEmpty
                        ? NetworkImage(image)
                        : null,
                    child: image.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  trailing: hasUnreadMessages
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            popButton(context, chatMap, uId),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Text(
                                myUnreadCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        )
                      : popButton(context, chatMap, uId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
