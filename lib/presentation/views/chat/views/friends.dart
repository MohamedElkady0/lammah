import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/function/date_utils.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/domian/chat/chat_cubit.dart'; // تأكد من المسار
import 'package:lammah/presentation/views/chat/views/chat_send_res.dart';
import 'package:lammah/presentation/views/chat/widget/user_avatar_with_status.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام BlocListener للاستماع لنتائج العمليات (نجاح/فشل)
    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is FriendRequestStateChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isFriendRequestSent
                    ? 'تم إرسال طلب الصداقة بنجاح'
                    : 'لا يمكن إرسال الطلب (قد تكون محظوراً)',
              ),
              backgroundColor: state.isFriendRequestSent
                  ? Colors.green
                  : Colors.red,
            ),
          );
        }
        if (state is UserBlockedStateChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حظر المستخدم بنجاح'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is ChatFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is ChatSuccess) {
          // يمكن استخدامه عند قبول/رفض الصداقة إذا أردت إشعاراً
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأصدقاء'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'أصدقائي'),
              Tab(text: 'طلبات الصداقة'),
              Tab(text: 'إضافة صديق'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFriendsList(),
            _buildFriendRequestsList(),
            _buildSuggestionsList(),
          ],
        ),
      ),
    );
  }

  // --- 1. قائمة الأصدقاء ---
  Widget _buildFriendsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection(AuthString.fSUsers)
          .doc(_currentUserUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> friendIds = userData['friends'] ?? [];

        if (friendIds.isEmpty) {
          return const Center(child: Text('ليس لديك أصدقاء بعد.'));
        }

        return _buildUserListFromIds(friendIds);
      },
    );
  }

  // --- 2. قائمة طلبات الصداقة ---
  Widget _buildFriendRequestsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection(AuthString.fSUsers)
          .doc(_currentUserUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> requestIds =
            userData['friendRequestsReceived'] ?? [];

        if (requestIds.isEmpty) {
          return const Center(child: Text('لا توجد طلبات صداقة حالية.'));
        }

        return _buildUserListFromIds(requestIds, isRequestList: true);
      },
    );
  }

  // --- 3. قائمة الاقتراحات ---
  Widget _buildSuggestionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').limit(50).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('حدث خطأ');
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(_currentUserUid).get(),
          builder: (context, currentUserDoc) {
            if (!currentUserDoc.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final myData = currentUserDoc.data!.data() as Map<String, dynamic>?;
            if (myData == null) return const Text("بياناتك غير موجودة");

            final List<dynamic> myFriends = myData['friends'] ?? [];
            final List<dynamic> mySentRequests =
                myData['friendRequestsSent'] ?? [];
            final List<dynamic> myReceivedRequests =
                myData['friendRequestsReceived'] ?? [];
            final List<dynamic> myBlockedUsers = myData['blockedUsers'] ?? [];

            final Set<String> excludedUids = {
              ...myFriends,
              ...mySentRequests,
              ...myReceivedRequests,
              ...myBlockedUsers,
              _currentUserUid,
            }.map((e) => e.toString()).toSet();

            final suggestions = snapshot.data!.docs
                .where((doc) => !excludedUids.contains(doc.id))
                .toList();

            if (suggestions.isEmpty) {
              return const Center(
                child: Text('لا توجد اقتراحات جديدة حالياً.'),
              );
            }

            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return _buildUserTile(suggestions[index], isSuggestion: true);
              },
            );
          },
        );
      },
    );
  }

  // --- بناء القائمة من IDs ---
  Widget _buildUserListFromIds(
    List<dynamic> userIds, {
    bool isRequestList = false,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(AuthString.fSUsers)
          .where(FieldPath.documentId, whereIn: userIds)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildUserTile(
              snapshot.data!.docs[index],
              isRequest: isRequestList,
            );
          },
        );
      },
    );
  }

  // --- بناء العنصر الواحد (User Tile) ---
  Widget _buildUserTile(
    DocumentSnapshot userDoc, {
    bool isRequest = false,
    bool isSuggestion = false,
  }) {
    final userData = userDoc.data() as Map<String, dynamic>;
    final String name = userData['name'] ?? 'Unknown';
    final String image = userData['image'] ?? '';
    final String uid = userDoc.id;
    final bool isOnline = userData['isOnline'] ?? false;
    final Timestamp? lastSeen = userData['lastSeen'];

    return ListTile(
      leading: UserAvatarWithStatus(image: image, isOnline: isOnline),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: !isRequest && !isSuggestion
          ? Text(
              isOnline ? 'متصل الآن' : formatLastSeen(lastSeen),
              style: TextStyle(
                color: isOnline ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            )
          : null,
      trailing: _buildTrailingButton(isRequest, isSuggestion, uid, name, image),
      onTap: () {
        if (!isRequest && !isSuggestion) {
          _navigateToChat(context, name, image, uid);
        }
      },
    );
  }

  // --- الأزرار الجانبية (مع ربطها بالـ Cubit) ---
  Widget _buildTrailingButton(
    bool isRequest,
    bool isSuggestion,
    String uid,
    String name,
    String image,
  ) {
    // الحصول على الـ Cubit
    final cubit = context.read<ChatCubit>();

    if (isRequest) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'قبول',
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () =>
                cubit.acceptFriendRequest(uid), // استدعاء الـ Cubit
          ),
          IconButton(
            tooltip: 'رفض',
            icon: const Icon(Icons.cancel, color: Colors.orange),
            onPressed: () =>
                cubit.rejectFriendRequest(uid), // استدعاء الـ Cubit
          ),
          IconButton(
            tooltip: 'حظر',
            icon: const Icon(Icons.block, color: Colors.red),
            onPressed: () => cubit.blockUser(uid), // استدعاء الـ Cubit
          ),
        ],
      );
    } else if (isSuggestion) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('إضافة'),
        onPressed: () => cubit.sendFriendRequest(uid), // استدعاء الـ Cubit
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.chat, color: Colors.blue),
        onPressed: () => _navigateToChat(context, name, image, uid),
      );
    }
  }

  // الانتقال للشات باستخدام ChatCubit helper
  void _navigateToChat(
    BuildContext context,
    String name,
    String image,
    String uid,
  ) {
    final cubit = context.read<ChatCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendResChat(
          userName: name,
          userImage: image,
          uid: uid,
          isGroupChat: false,
          chatId: cubit.chatRoomId(uid), // استخدام دالة الـ Cubit لحساب المعرف
        ),
      ),
    );
  }
}
