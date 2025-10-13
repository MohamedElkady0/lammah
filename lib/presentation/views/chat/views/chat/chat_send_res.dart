import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/presentation/views/chat/views/chat/chat_widget.dart';
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
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(widget.userImage),
            ),
            const SizedBox(width: 10),
            Text(widget.userName),
          ],
        ),
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
                      String senderId = message['senderId'] ?? '';
                      return currentUser == senderId
                          ? ChatWidget(message: message)
                          : ChatWidgetForFried(message: message);
                    },
                  );
                },
              ),
            ),
            TextField(
              controller: control,
              decoration: InputDecoration(
                prefix: IconButton(
                  onPressed: () {
                    // Handle image selection
                  },
                  icon: const Icon(Icons.image),
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
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
