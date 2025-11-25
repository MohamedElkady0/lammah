// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lammah/core/function/send_call_notification.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/matched_user.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/location/location_cubit.dart';
import 'package:lammah/domian/upload/upload_cubit.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.user,
    required this.auth,
    required this.locationCubit,
  }) : super(ChatInitial());

  final String _currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. أضف متغيرات جديدة لإدارة حالة التسجيل
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? _audioPath;
  final AuthCubit user;
  final UploadCubit auth;
  final LocationCubit locationCubit;

  sendMessageText({
    required bool isGroupChat,
    required String chatId,
    required String control,
    required String uid,
    required String userImage,
    required String userName,
  }) async {
    final collectionPath = isGroupChat ? 'groups' : 'chat';
    final messageSubCollection = isGroupChat ? 'messages' : 'message';

    if (control.trim().isNotEmpty) {
      final uuid = const Uuid().v4();
      try {
        // 1. إذا كانت محادثة فردية، تأكد من إنشاء الغرفة أولاً (أو تحديث بياناتها)
        // في الجروبات، الغرفة موجودة بالفعل لذا لا نحتاج لـ .set() الكاملة هنا
        if (!isGroupChat) {
          await FirebaseFirestore.instance
              .collection('chat')
              .doc(chatId) // استخدم widget.chatId بدلاً من chatRoomId()
              .set(
                {
                  'senderName': user.currentUserInfo?.name ?? '',
                  'senderImage': user.currentUserInfo?.image ?? '',
                  'senderId': user.currentUserInfo?.userId ?? '',
                  'receiverName': userName,
                  'receiverImage': userImage,
                  'receiverId': uid,
                  'partial': [user.currentUserInfo?.userId ?? '', uid],
                  'chatRoomId': chatId,
                  'date': Timestamp.now(),
                },
                SetOptions(merge: true),
              ); // merge مهم جداً لعدم مسح البيانات الأخرى
        }

        // 2. إضافة الرسالة في الـ Collection الصحيح
        await FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(chatId)
            .collection(messageSubCollection)
            .add({
              // استخدم .add أو .doc(uuid).set
              'message': control,
              'userId': user.currentUserInfo?.userId ?? '', // أو senderId
              'senderId': user.currentUserInfo?.userId ?? '',
              'date': Timestamp.now(),
              'image': '',
              'messageId': uuid,
              'type': 'text',
            });

        // 3. تحديث "آخر رسالة" والعدادات في المستند الرئيسي
        // ملاحظة: في الجروبات نحتاج لتحديث العداد لكل الأعضاء
        // هذا الجزء قد يتطلب Cloud Function للأداء الأفضل، لكن هنا مثال بسيط

        Map<String, dynamic> updateData = {
          'lastMessage': control,
          'date': Timestamp.now(),
          // تحديث timestamp للجروبات باسم مختلف اذا لزم
          if (isGroupChat) 'lastMessageTimestamp': Timestamp.now(),
        };

        // تحديث عداد الرسائل غير المقروءة
        if (!isGroupChat) {
          // للمحادثة الفردية: زود عداد الطرف الآخر
          updateData['unreadCount.$uid'] = FieldValue.increment(1);
        } else {
          // للجروبات: هذا معقد من الكود مباشرة، يفضل Cloud Function
          // لأنك تحتاج لزيادة العداد لكل الأعضاء ما عدا المرسل
          // كحل مؤقت: لا تحدث العداد هنا للجروبات، أو قم بجلب قائمة الأعضاء وتحديثهم
        }

        await FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(chatId)
            .update(updateData);

        await notifiMessage(typeMessage: 'Text', message: control, uid: uid);
        emit(ChatSuccess());
      } catch (e) {
        emit(ChatFailure('Failed to send message: $e'));
      }
    }
  }

  addFriends(String recipientUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    // أولاً، تحقق مما إذا كان هذا المستخدم قد حظرك
    final recipientDoc = await firestore
        .collection(AuthString.fSUsers)
        .doc(recipientUid)
        .get();
    final List<dynamic> blockedByRecipient =
        recipientDoc.data()?['blockedUsers'] ?? [];
    if (blockedByRecipient.contains(currentUserUid)) {
      emit(FriendRequestStateChanged(isFriendRequestSent: false));
    }

    // 1. تحديث قاعدة البيانات كما في السابق
    firestore.collection(AuthString.fSUsers).doc(recipientUid).update({
      'friendRequestsReceived': FieldValue.arrayUnion([currentUserUid]),
    });
    firestore.collection(AuthString.fSUsers).doc(currentUserUid).update({
      'friendRequestsSent': FieldValue.arrayUnion([recipientUid]),
    });

    // 2. إرسال الإشعار
    try {
      // جلب بياناتك (المرسل) وبيانات المستلم (FCM Token)
      final myDoc = await firestore
          .collection(AuthString.fSUsers)
          .doc(currentUserUid)
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
      emit(FriendRequestStateChanged(isFriendRequestSent: true));
    } catch (e) {
      print("Failed to send friend request notification: $e");
    }
  }

  sendVideoCall({
    required String chatId,
    required String uid,
    required String userName,
    required String userImage,
    required String currentUserUid,
  }) async {
    final receiverDoc = await FirebaseFirestore.instance
        .collection(AuthString.fSUsers)
        .doc(uid)
        .get();
    final receiverData = receiverDoc.data() as Map<String, dynamic>;
    final receiverFcmToken = receiverData['fcmToken'];

    if (receiverFcmToken != null) {
      // 2. إنشاء مستند المكالمة
      final callDoc = FirebaseFirestore.instance.collection('calls').doc();
      final callId = callDoc.id;
      final channelName = callId; // استخدام ID المستند كاسم للقناة لضمان التفرد

      await callDoc.set({
        'callerId': user.currentUserInfo?.userId ?? '',
        'callerName': user.currentUserInfo?.name ?? '',
        'callerImage': user.currentUserInfo?.image ?? '',
        'receiverId': uid,
        'receiverName': userName,
        'receiverImage': userImage,
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
        user.currentUserInfo?.name ?? "Someone",
        '',
        true,
      );
      emit(NavChatCall());
    }
  }

  void markMessagesAsRead(String uid) {
    final currentUser = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('chat').doc(chatRoomId(uid)).update({
      'unreadCount.$currentUser': 0,
    });
  }

  String chatRoomId(String uid) {
    List<String> userIds = [FirebaseAuth.instance.currentUser!.uid, uid];
    userIds.sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  editMessageText({
    required String editController,
    required String messageId,
    required String uId,
  }) {
    final newText = editController.trim();
    if (newText.isNotEmpty) {
      // تحديث الرسالة في Firestore وإضافة علامة التعديل
      FirebaseFirestore.instance
          .collection('chat')
          .doc(chatRoomId(uId))
          .collection('message')
          .doc(messageId)
          .update({
            'message': newText,
            'isEdited': true, // حقل جديد لتتبع التعديل
          });
    }
  }

  deleteMessage({required String messageId, required String uId}) {
    FirebaseFirestore.instance
        .collection('chat')
        .doc(chatRoomId(uId))
        .collection('message')
        .doc(messageId)
        .delete();
  }

  Stream<QuerySnapshot> getMessageStream({
    required bool isGroupChat,
    required String chatId,
  }) {
    if (isGroupChat) {
      return FirebaseFirestore.instance
          .collection('groups')
          .doc(chatId)
          .collection('messages')
          .orderBy('date')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('chat')
          .doc(chatId)
          .collection('message')
          .orderBy('date')
          .snapshots();
    }
  }

  sendImage({
    required String userName,
    required String userImage,
    required String uid,

    imagesToSend,
    caption,
  }) async {
    // 1. اختيار عدة صور
    List<XFile> selectedImages = await auth.pickMultipleImages();

    if (selectedImages.isNotEmpty) {
      try {
        // 3. رفع الصور إلى Storage
        List<String> imageUrls = await auth.uploadMultipleImagesAndGetUrls(
          imagesToSend,
        );

        // 4. إرسال الرسالة إلى Firestore
        final uuid = const Uuid().v4();

        // التأكد من أن chatRoom document موجود
        await FirebaseFirestore.instance
            .collection('chat')
            .doc(chatRoomId(uid))
            .set(
              {
                'senderName': user.currentUserInfo?.name ?? '',
                'senderImage': user.currentUserInfo?.image ?? '',
                'senderId': user.currentUserInfo?.userId ?? '',
                'receiverName': userName,
                'receiverImage': userImage,
                'receiverId': uid,
                'partial': [user.currentUserInfo?.userId ?? '', uid],
                'chatRoomId': chatRoomId(uid),
                'date': Timestamp.now(),
              },
              SetOptions(merge: true),
            ); // استخدام merge لتجنب الكتابة فوق البيانات

        await FirebaseFirestore.instance
            .collection('chat')
            .doc(chatRoomId(uid))
            .collection('message')
            .doc(uuid)
            .set({
              'type': 'image', // نوع الرسالة
              'senderId': user.currentUserInfo?.userId ?? '',
              'date': Timestamp.now(),
              'imageUrls': imageUrls, // قائمة روابط الصور
              'caption': caption, // الشرح المكتوب
              'messageId': uuid,
            });
        // تحديث مستند المحادثة الرئيسي
        FirebaseFirestore.instance
            .collection('chat')
            .doc(chatRoomId(uid))
            .update({
              'lastMessageImage': imageUrls, // أو وصف للملف
              'date': Timestamp.now(),
              'unreadCount.$uid': FieldValue.increment(
                1,
              ), // زيادة العداد للمستقبل
            });
        await notifiMessage(
          typeMessage: 'Image',
          message: imageUrls.first,
          uid: uid,
        );
      } catch (e) {
        emit(ChatFailure('Failed to send image message: $e'));
      }
    }
  }

  Future<void> sendVideo({required String uid}) async {
    final ImagePicker picker = ImagePicker();

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

      final messageId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('chat')
          .doc(chatRoomId(uid))
          .collection('message')
          .doc(messageId)
          .set({
            'type': 'video', // نوع الرسالة
            'senderId': user.currentUserInfo?.userId ?? '',
            'date': Timestamp.now(),
            'videoUrl': videoUrl,
            'fileName': videoFile.name, // حفظ اسم الملف
            'messageId': messageId,
          });
      // تحديث مستند المحادثة الرئيسي
      FirebaseFirestore.instance.collection('chat').doc(chatRoomId(uid)).update(
        {
          'lastMessageVideo': videoUrl, // أو وصف للملف
          'date': Timestamp.now(),
          'unreadCount.$uid': FieldValue.increment(1), // زيادة العداد للمستقبل
        },
      );
      await notifiMessage(typeMessage: messageId, message: videoUrl, uid: uid);
    }
  }

  // داخل _SendResChatState
  Future<void> sendFile({required String uid}) async {
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

      final messageId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('chat')
          .doc(chatRoomId(uid))
          .collection('message')
          .doc(messageId)
          .set({
            'type': 'file',
            'senderId': user.currentUserInfo?.userId ?? '',
            'date': Timestamp.now(),
            'fileUrl': fileUrl,
            'fileName': fileName,
            'messageId': messageId,
          });
      // تحديث مستند المحادثة الرئيسي
      FirebaseFirestore.instance.collection('chat').doc(chatRoomId(uid)).update(
        {
          'lastMessageFile': fileUrl, // أو وصف للملف
          'date': Timestamp.now(),
          'unreadCount.$uid': FieldValue.increment(1), // زيادة العداد للمستقبل
        },
      );
      await notifiMessage(typeMessage: 'File', message: fileUrl, uid: uid);
    }
  }

  notifiMessage({
    required String typeMessage,
    required String message,
    required String uid,
  }) async {
    // 1. احصل على بيانات المستقبل (FCM Token)
    final receiverDoc = await FirebaseFirestore.instance
        .collection(AuthString.fSUsers)
        .doc(uid)
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
        'senderName': user.currentUserInfo?.name ?? 'مستخدم جديد',
        'senderImage':
            user.currentUserInfo?.image ?? '', // رابط الصورة الشخصية للمرسل
        'messageContent': message, // محتوى الرسالة
        'chatRoomId': chatRoomId(uid),
        'senderId': user.currentUserInfo?.userId ?? '',
      });
    }
  }

  void blockUser(String userToBlockUid) {
    // هذا سيتم استدعاؤه عندما تضغط على أيقونة الحظر من قائمة الطلبات
    // سيقوم برفض الطلب أولاً ثم حظر المستخدم نهائياً

    final batch = _firestore.batch();

    // 1. (مثل الرفض) إزالة الطلب من قائمة طلباتك المستلمة
    batch.update(_firestore.collection('users').doc(_currentUserUid), {
      'friendRequestsReceived': FieldValue.arrayRemove([userToBlockUid]),
    });

    // 2. (مثل الرفض) إزالة الطلب من قائمة طلباته المرسلة
    batch.update(_firestore.collection('users').doc(userToBlockUid), {
      'friendRequestsSent': FieldValue.arrayRemove([_currentUserUid]),
    });

    // 3. (الخطوة الجديدة) إضافة هذا المستخدم إلى قائمة الحظر الخاصة بك
    batch.update(_firestore.collection('users').doc(_currentUserUid), {
      'blockedUsers': FieldValue.arrayUnion([userToBlockUid]),
    });

    // 4. (اختياري ولكن موصى به) إضافتك إلى قائمة "محظور من قبل" لديه
    // هذا يساعد في منعه من رؤيتك أيضاً
    batch.update(_firestore.collection('users').doc(userToBlockUid), {
      'blockedBy': FieldValue.arrayUnion([_currentUserUid]),
    });

    // تنفيذ كل العمليات دفعة واحدة
    batch.commit().then((_) {
      emit(UserBlockedStateChanged(isUserBlocked: true));
    });
  }

  void sendFriendRequest(String recipientUid) async {
    // أولاً، تحقق مما إذا كان هذا المستخدم قد حظرك
    final recipientDoc = await _firestore
        .collection('users')
        .doc(recipientUid)
        .get();
    final List<dynamic> blockedByRecipient =
        recipientDoc.data()?['blockedUsers'] ?? [];
    if (blockedByRecipient.contains(_currentUserUid)) {
      emit(FriendRequestStateChanged(isFriendRequestSent: false));
    }

    // 1. تحديث قاعدة البيانات كما في السابق
    _firestore.collection('users').doc(recipientUid).update({
      'friendRequestsReceived': FieldValue.arrayUnion([_currentUserUid]),
    });
    _firestore.collection('users').doc(_currentUserUid).update({
      'friendRequestsSent': FieldValue.arrayUnion([recipientUid]),
    });

    // 2. إرسال الإشعار
    try {
      // جلب بياناتك (المرسل) وبيانات المستلم (FCM Token)
      final myDoc = await _firestore
          .collection('users')
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

  void createGroup({required String groupNameController}) async {
    final List<String> selectedMemberIds = [];
    if (groupNameController.trim().isEmpty || selectedMemberIds.isEmpty) {
      // عرض رسالة خطأ
      return;
    }

    emit(ChatLoading());

    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final members = [currentUserUid, ...selectedMemberIds];

    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .add({
            'groupName': groupNameController.trim(),
            'groupImage': '', // يمكنك إضافة منطق رفع صورة
            'createdBy': currentUserUid,
            'createdAt': Timestamp.now(),
            'admins': [currentUserUid],
            'members': members,
            'lastMessage': 'تم إنشاء المجموعة.',
            'lastMessageTimestamp': Timestamp.now(),
            'lastMessageSenderName': 'النظام',
            'unreadCount': {for (var member in members) member: 0},
          });

      emit(NavChat());
    } catch (e) {
      emit(ChatFailure('Failed to create group: $e'));
    }
  }

  // دالة حساب ChatRoomId (نفس الموجودة في MapScreen)
  String getChatRoomId(String user1, String user2) {
    List<String> userIds = [user1, user2];
    userIds.sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  void acceptFriendRequest(String senderUid) {
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

  void rejectFriendRequest(String senderUid) {
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

  Future<void> findNewTrip() async {
    // setState(() {
    //   _isFindingTrip = true;
    //   _matchedUser = null;
    //   _animationController.reset();
    // });

    if (user.currentUserInfo == null) {
      // setState(() {
      //   _isFindingTrip = false;
      // });
      // return;
    }

    // --- منطق اختيار مستخدم عشوائي ---
    final randomId = FirebaseFirestore.instance.collection('users').doc().id;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isOnline', isEqualTo: true) // ابحث فقط في المستخدمين الأونلاين
        .where(FieldPath.documentId, isNotEqualTo: user.currentUserInfo?.userId)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: randomId)
        .limit(1)
        .get();

    DocumentSnapshot? userDoc;
    if (querySnapshot.docs.isNotEmpty) {
      userDoc = querySnapshot.docs.first;
    } else {
      // إذا لم نجد أحداً، حاول البحث مرة أخرى من بداية القائمة
      final fallbackQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .where(
            FieldPath.documentId,
            isNotEqualTo: user.currentUserInfo?.userId,
          )
          .limit(1)
          .get();
      if (fallbackQuery.docs.isNotEmpty) {
        userDoc = fallbackQuery.docs.first;
      }
    }

    if (userDoc != null) {
      final userData = userDoc.data() as Map<String, dynamic>;
      // تأكد من أن المستخدم لديه بيانات الموقع
      if (userData['latitude'] != null && userData['longitude'] != null) {
        final position = LatLng(userData['latitude'], userData['longitude']);

        final matchedUser = MatchedUser(
          uid: userDoc.id,
          name: userData['name'] ?? 'مستخدم',
          image: userData['image'] ?? '',
          country: userData['userCountry'] ?? 'غير معروف',
          position: position,
        );
        // _startFlightAnimation(
        //   locationCubit.currentPosition!,
        //   position,
        //   matchedUser,
        // );
      } else {
        // إذا لم يكن لديه بيانات موقع، ابحث مرة أخرى
        findNewTrip();
      }
    } else {
      // setState(() {
      //   _isFindingTrip = false;
      // });
      emit(ChatFailure('No available users found for matching.'));
    }
  }

  // 2. وظيفة لبدء التسجيل
  Future<void> startRecording() async {
    try {
      // 1. اطلب الإذن باستخدام permission_handler
      var status = await Permission.microphone.request();

      // 2. تحقق من حالة الإذن بعد الطلب
      if (status.isGranted) {
        // إذا تم منح الإذن، ابدأ التسجيل
        final appDocumentsDir = await getApplicationDocumentsDirectory();
        _audioPath = '${appDocumentsDir.path}/${const Uuid().v4()}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: _audioPath!);

        isRecording = true;
        emit(RecordingStateChanged(isRecording));
      } else {
        emit(ChatFailure("تم رفض إذن استخدام الميكروفون"));
      }
    } catch (e) {
      emit(ChatFailure('Failed to start recording: $e'));
      isRecording = false;
      emit(RecordingStateChanged(isRecording));
    }
  }

  // 3. وظيفة لإيقاف التسجيل ورفع الملف وإرسال الرسالة
  Future<void> stopRecordingAndSend({
    required String chatRoomId,
    required Map<String, dynamic> currentUserInfo,
  }) async {
    try {
      final path = await _audioRecorder.stop();
      isRecording = false;
      emit(RecordingStateChanged(isRecording));

      if (path != null) {
        final audioFile = File(path);

        // 1. رفع الملف الصوتي إلى Firebase Storage
        final fileId = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('audio_messages')
            .child('$fileId.m4a');
        await ref.putFile(audioFile);
        final audioUrl = await ref.getDownloadURL();

        // 2. الحصول على مدة المقطع الصوتي (ميزة إضافية ومهمة)
        final player = AudioPlayer();
        final duration = await player.setFilePath(path);
        player.dispose();

        // 3. إرسال الرسالة إلى Firestore
        final messageId = const Uuid().v4();
        await FirebaseFirestore.instance
            .collection('chat')
            .doc(chatRoomId)
            .collection('message')
            .doc(messageId)
            .set({
              'type': 'audio', // نوع الرسالة
              'senderId': currentUserInfo['userId'] ?? '',
              'date': Timestamp.now(),
              'audioUrl': audioUrl,
              'duration':
                  duration?.inMilliseconds ?? 0, // حفظ المدة بالمللي ثانية
              'messageId': messageId,
            });
        // تحديث مستند المحادثة الرئيسي
        FirebaseFirestore.instance.collection('chat').doc(chatRoomId).update({
          'lastRecord': audioUrl, // أو وصف للملف
          'date': Timestamp.now(),
          'unreadCount.${currentUserInfo['userId']}': FieldValue.increment(
            1,
          ), // زيادة العداد للمستقبل
        });
      }
    } catch (e) {
      emit(ChatFailure('Failed to send audio message: $e'));
    }
  }
}
