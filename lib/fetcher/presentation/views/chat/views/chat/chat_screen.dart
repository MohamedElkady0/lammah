import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/chat/views/chat/chat_send_res.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
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

              return Padding(
                padding: const EdgeInsets.all(8),
                child: ListTile(
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
                  title: Text(name),
                  subtitle: Text(
                    chatMap['date']?.toDate().toString() ?? 'No date',
                  ),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: image.isNotEmpty
                        ? NetworkImage(image)
                        : null,
                    child: image.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'option1') {
                        // Handle delete
                      } else if (value == 'option2') {
                        // Handle block
                      }
                    },
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem(
                          value: 'option1',
                          child: Text('Delete'),
                        ),
                        const PopupMenuItem(
                          value: 'option2',
                          child: Text('Block'),
                        ),
                      ];
                    },
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
