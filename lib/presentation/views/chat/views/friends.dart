import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lammah/core/utils/auth_string.dart';

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
    return Scaffold(
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
          // التاب الأول: عرض الأصدقاء الحاليين
          _buildFriendsList(),
          // التاب الثاني: عرض طلبات الصداقة الواردة
          _buildFriendRequestsList(),
          // التاب الثالث: عرض اقتراحات الأصدقاء
          _buildSuggestionsList(),
        ],
      ),
    );
  }

  // --- ويدجت لعرض قائمة الأصدقاء ---
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

  // --- ويدجت لعرض قائمة طلبات الصداقة ---
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

  // --- ويدجت لعرض قائمة الاقتراحات ---
  Widget _buildSuggestionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(AuthString.fSUsers)
          .where('uid', isNotEqualTo: _currentUserUid)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // هذا الجزء مهم لفلترة الاقتراحات
        return FutureBuilder<DocumentSnapshot>(
          future: _firestore
              .collection(AuthString.fSUsers)
              .doc(_currentUserUid)
              .get(),
          builder: (context, currentUserDoc) {
            if (!currentUserDoc.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final myData = currentUserDoc.data!.data() as Map<String, dynamic>;
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
              return const Center(child: Text('لا توجد اقتراحات جديدة.'));
            }

            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final userDoc = suggestions[index];
                return _buildUserTile(userDoc, isSuggestion: true);
              },
            );
          },
        );
      },
    );
  }

  // --- ويدجت عامة لبناء قائمة المستخدمين من قائمة ID ---
  Widget _buildUserListFromIds(
    List<dynamic> userIds, {
    bool isRequestList = false,
  }) {
    // جلب بيانات المستخدمين بناءً على IDs الخاصة بهم
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
            final userDoc = snapshot.data!.docs[index];
            return _buildUserTile(userDoc, isRequest: isRequestList);
          },
        );
      },
    );
  }

  // --- ويدجت لعرض عنصر مستخدم واحد (Tile) ---
  Widget _buildUserTile(
    DocumentSnapshot userDoc, {
    bool isRequest = false,
    bool isSuggestion = false,
  }) {
    final userData = userDoc.data() as Map<String, dynamic>;
    final String name = userData['name'] ?? 'Unknown';
    final String image = userData['image'] ?? '';
    final String uid = userDoc.id;

    Widget trailingButton;
    if (isRequest) {
      trailingButton = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () => _acceptFriendRequest(uid),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => _rejectFriendRequest(uid),
          ),
        ],
      );
    } else if (isSuggestion) {
      trailingButton = ElevatedButton(
        child: const Text('إضافة'),
        onPressed: () => _sendFriendRequest(uid),
      );
    } else {
      // لعرض الأصدقاء الحاليين، يمكن وضع زر محادثة أو لا شيء
      trailingButton = const Icon(Icons.chat);
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
        child: image.isEmpty ? const Icon(Icons.person) : null,
      ),
      title: Text(name),
      trailing: trailingButton,
      // يمكنك إضافة onTap للانتقال للمحادثة مع الأصدقاء
    );
  }

  // --- وظائف التعامل مع طلبات الصداقة ---

  void _sendFriendRequest(String recipientUid) {
    // إضافة UID الخاص بك إلى قائمة طلبات المستلم
    _firestore.collection(AuthString.fSUsers).doc(recipientUid).update({
      'friendRequestsReceived': FieldValue.arrayUnion([_currentUserUid]),
    });
    // إضافة UID المستلم إلى قائمة طلباتك المرسلة
    _firestore.collection(AuthString.fSUsers).doc(_currentUserUid).update({
      'friendRequestsSent': FieldValue.arrayUnion([recipientUid]),
    });
  }

  void _acceptFriendRequest(String senderUid) {
    // كتابة مجمعة (Batch Write) لضمان تنفيذ كل العمليات معاً
    final batch = _firestore.batch();

    // 1. إضافة كل منكم إلى قائمة أصدقاء الآخر
    batch.update(
      _firestore.collection(AuthString.fSUsers).doc(_currentUserUid),
      {
        'friends': FieldValue.arrayUnion([senderUid]),
      },
    );
    batch.update(_firestore.collection(AuthString.fSUsers).doc(senderUid), {
      'friends': FieldValue.arrayUnion([_currentUserUid]),
    });

    // 2. إزالة الطلب من كلا القائمتين
    batch.update(
      _firestore.collection(AuthString.fSUsers).doc(_currentUserUid),
      {
        'friendRequestsReceived': FieldValue.arrayRemove([senderUid]),
      },
    );
    batch.update(_firestore.collection(AuthString.fSUsers).doc(senderUid), {
      'friendRequestsSent': FieldValue.arrayRemove([_currentUserUid]),
    });

    batch.commit();
  }

  void _rejectFriendRequest(String senderUid) {
    final batch = _firestore.batch();

    // إزالة الطلب من كلا القائمتين
    batch.update(
      _firestore.collection(AuthString.fSUsers).doc(_currentUserUid),
      {
        'friendRequestsReceived': FieldValue.arrayRemove([senderUid]),
      },
    );
    batch.update(_firestore.collection(AuthString.fSUsers).doc(senderUid), {
      'friendRequestsSent': FieldValue.arrayRemove([_currentUserUid]),
    });

    batch.commit();
  }
}
