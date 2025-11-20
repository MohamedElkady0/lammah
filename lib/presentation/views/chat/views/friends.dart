import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lammah/core/function/date_utils.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/presentation/views/chat/views/chat/chat_send_res.dart';
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

  Widget _buildUserTile(
    DocumentSnapshot userDoc, {
    bool isRequest = false,
    bool isSuggestion = false,
  }) {
    final userData = userDoc.data() as Map<String, dynamic>;
    final String name = userData['name'] ?? 'Unknown';
    final String image = userData['image'] ?? '';
    final String uid = userDoc.id;

    // جلب بيانات الحالة (أونلاين / آخر ظهور)
    final bool isOnline = userData['isOnline'] ?? false;
    final Timestamp? lastSeen = userData['lastSeen'];

    return ListTile(
      // استخدام ويدجت الصورة مع حالة الأونلاين
      leading: UserAvatarWithStatus(image: image, isOnline: isOnline),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      // عرض حالة الاتصال فقط للأصدقاء الحاليين
      subtitle: !isRequest && !isSuggestion
          ? Text(
              isOnline ? 'متصل الآن' : formatLastSeen(lastSeen),
              style: TextStyle(
                color: isOnline ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            )
          : null,

      // استدعاء الدالة المساعدة لبناء الأزرار الجانبية
      trailing: _buildTrailingButton(isRequest, isSuggestion, uid, name, image),

      onTap: () {
        // الانتقال للمحادثة فقط إذا كانوا أصدقاء
        if (!isRequest && !isSuggestion) {
          _navigateToChat(name, image, uid);
        }
      },
    );
  }

  Widget _buildTrailingButton(
    bool isRequest,
    bool isSuggestion,
    String uid,
    String name,
    String image,
  ) {
    if (isRequest) {
      // حالة طلب الصداقة: عرض أزرار قبول، رفض، حظر
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'قبول',
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () => _acceptFriendRequest(uid),
          ),
          IconButton(
            tooltip: 'رفض',
            icon: const Icon(Icons.cancel, color: Colors.orange),
            onPressed: () => _rejectFriendRequest(uid),
          ),
          IconButton(
            tooltip: 'حظر',
            icon: const Icon(Icons.block, color: Colors.red),
            onPressed: () => _blockUser(uid),
          ),
        ],
      );
    } else if (isSuggestion) {
      // حالة الاقتراح: زر إضافة
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('إضافة'),
        onPressed: () => _sendFriendRequest(uid),
      );
    } else {
      // حالة الصديق الحالي: زر المحادثة
      return IconButton(
        icon: const Icon(Icons.chat, color: Colors.blue),
        onPressed: () => _navigateToChat(name, image, uid),
      );
    }
  }

  // دالة مساعدة للانتقال للشات (لتجنب تكرار الكود)
  void _navigateToChat(String name, String image, String uid) {
    // تأكد من استيراد SendResChat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendResChat(
          userName: name,
          userImage: image,
          uid: uid,
          isGroupChat: false,
          chatId: _getChatRoomId(_currentUserUid, uid), // دالة حساب الـ ID
        ),
      ),
    );
  }

  // دالة حساب ChatRoomId (نفس الموجودة في MapScreen)
  String _getChatRoomId(String user1, String user2) {
    List<String> userIds = [user1, user2];
    userIds.sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  // --- وظائف التعامل مع طلبات الصداقة ---

  void _sendFriendRequest(String recipientUid) async {
    var scaffoldMessengers = ScaffoldMessenger.of(context);
    // أولاً، تحقق مما إذا كان هذا المستخدم قد حظرك
    final recipientDoc = await _firestore
        .collection(AuthString.fSUsers)
        .doc(recipientUid)
        .get();
    final List<dynamic> blockedByRecipient =
        recipientDoc.data()?['blockedUsers'] ?? [];
    if (blockedByRecipient.contains(_currentUserUid)) {
      scaffoldMessengers.showSnackBar(
        const SnackBar(content: Text('لا يمكنك إرسال طلب لهذا المستخدم.')),
      );
      return;
    }

    // 1. تحديث قاعدة البيانات كما في السابق
    _firestore.collection(AuthString.fSUsers).doc(recipientUid).update({
      'friendRequestsReceived': FieldValue.arrayUnion([_currentUserUid]),
    });
    _firestore.collection(AuthString.fSUsers).doc(_currentUserUid).update({
      'friendRequestsSent': FieldValue.arrayUnion([recipientUid]),
    });

    // 2. إرسال الإشعار
    try {
      // جلب بياناتك (المرسل) وبيانات المستلم (FCM Token)
      final myDoc = await _firestore
          .collection(AuthString.fSUsers)
          .doc(_currentUserUid)
          .get();
      final myName = myDoc.data()?['name'] ?? 'مستخدم';
      final receiverFcmToken = recipientDoc.data()?['fcmToken'];

      if (receiverFcmToken != null) {
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'sendFriendRequestNotification',
        );
        await callable.call(<String, dynamic>{
          'receiverFcmToken': receiverFcmToken,
          'senderName': myName,
        });
      }
    } catch (e) {
      print("Failed to send friend request notification: $e");
    }
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
  // داخل _FriendsScreenState

  void _blockUser(String userToBlockUid) {
    // هذا سيتم استدعاؤه عندما تضغط على أيقونة الحظر من قائمة الطلبات
    // سيقوم برفض الطلب أولاً ثم حظر المستخدم نهائياً

    final batch = _firestore.batch();
    var scaffoldMessengers = ScaffoldMessenger.of(context);

    // 1. (مثل الرفض) إزالة الطلب من قائمة طلباتك المستلمة
    batch.update(
      _firestore.collection(AuthString.fSUsers).doc(_currentUserUid),
      {
        'friendRequestsReceived': FieldValue.arrayRemove([userToBlockUid]),
      },
    );

    // 2. (مثل الرفض) إزالة الطلب من قائمة طلباته المرسلة
    batch.update(
      _firestore.collection(AuthString.fSUsers).doc(userToBlockUid),
      {
        'friendRequestsSent': FieldValue.arrayRemove([_currentUserUid]),
      },
    );

    // 3. (الخطوة الجديدة) إضافة هذا المستخدم إلى قائمة الحظر الخاصة بك
    batch.update(
      _firestore.collection(AuthString.fSUsers).doc(_currentUserUid),
      {
        'blockedUsers': FieldValue.arrayUnion([userToBlockUid]),
      },
    );

    // 4. (اختياري ولكن موصى به) إضافتك إلى قائمة "محظور من قبل" لديه
    // هذا يساعد في منعه من رؤيتك أيضاً
    batch.update(
      _firestore.collection(AuthString.fSUsers).doc(userToBlockUid),
      {
        'blockedBy': FieldValue.arrayUnion([_currentUserUid]),
      },
    );

    // تنفيذ كل العمليات دفعة واحدة
    batch.commit().then((_) {
      scaffoldMessengers.showSnackBar(
        const SnackBar(content: Text('تم حظر المستخدم بنجاح.')),
      );
    });
  }
}
