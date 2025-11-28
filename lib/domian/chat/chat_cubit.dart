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
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/matched_user.dart';
import 'package:lammah/data/model/message_model.dart';
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
    required this.upload,
    required this.locationCubit,
  }) : super(ChatInitial());

  final AuthCubit user;
  final UploadCubit upload;
  final LocationCubit locationCubit;

  final String _currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioRecorder _audioRecorder = AudioRecorder();

  // متغيرات الحالة
  bool isRecording = false;
  String? _audioPath;

  @override
  Future<void> close() {
    _audioRecorder.dispose(); // إغلاق مسجل الصوت
    return super.close();
  }

  // ---------------------------------------------------------------------------
  // Helper Function: Chat Room ID
  // ---------------------------------------------------------------------------
  String chatRoomId(String uid) {
    List<String> userIds = [_currentUserUid, uid];
    userIds.sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  // ---------------------------------------------------------------------------
  // 1. Send Text Message
  // ---------------------------------------------------------------------------
  Future<void> sendMessageText({
    required bool isGroupChat,
    required String chatId, // في الفردي يكون chatRoomId، في القروب يكون GroupId
    required String textMessage,
    required String receiverId,
    required String receiverImage,
    required String receiverName,
  }) async {
    if (textMessage.trim().isEmpty) return;

    // 1. إصدار حالة التحميل ليقوم الزر بإظهار Spinner
    emit(ChatLoading());

    final collectionPath = isGroupChat ? 'groups' : 'chat';
    final messageSubCollection = isGroupChat ? 'messages' : 'message';
    final uuid = const Uuid().v4();

    try {
      // أ) إعداد بيانات الغرفة (للمحادثات الفردية فقط)
      if (!isGroupChat) {
        await _firestore.collection('chat').doc(chatId).set({
          'senderName': user.currentUserInfo?.name ?? '',
          'senderImage': user.currentUserInfo?.image ?? '',
          'senderId': user.currentUserInfo?.userId ?? '',
          'receiverName': receiverName,
          'receiverImage': receiverImage,
          'receiverId': receiverId,
          'partial': [user.currentUserInfo?.userId ?? '', receiverId],
          'chatRoomId': chatId,
          'date': Timestamp.now(),
        }, SetOptions(merge: true));
      }

      // ب) إنشاء الموديل وإرسال الرسالة
      final messageData = MessageModel(
        messageId: uuid,
        senderId: user.currentUserInfo?.userId ?? '',
        senderName: user.currentUserInfo?.name ?? '',
        senderImage: user.currentUserInfo?.image ?? '',
        date: Timestamp.now(),
        message: textMessage,
        type: 'text',
        status: 'sent',
      ).toMap();

      await _firestore
          .collection(collectionPath)
          .doc(chatId)
          .collection(messageSubCollection)
          .doc(uuid) // يفضل استخدام doc(uuid).set بدلاً من add لضمان تطابق ID
          .set(messageData);

      // ج) تحديث آخر رسالة والعدادات
      Map<String, dynamic> updateData = {
        'lastMessage': textMessage,
        'date': Timestamp.now(),
      };

      if (isGroupChat) {
        updateData['lastMessageTimestamp'] = Timestamp.now();
      } else {
        updateData['unreadCount.$receiverId'] = FieldValue.increment(1);
      }

      await _firestore
          .collection(collectionPath)
          .doc(chatId)
          .update(updateData);

      // د) إرسال الإشعار
      await notifiMessage(
        typeMessage: 'Text',
        message: textMessage,
        uid: receiverId,
        chatId: chatId,
      );

      // هـ) إصدار حالة النجاح ليقوم الـ UI بمسح حقل النص
      emit(ChatSuccess());
    } catch (e) {
      emit(ChatFailure('Failed to send message: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Add Friends
  // ---------------------------------------------------------------------------
  Future<void> addFriends(String recipientUid) async {
    emit(ChatLoading());
    try {
      final recipientDoc = await _firestore
          .collection(AuthString.fSUsers)
          .doc(recipientUid)
          .get();
      final List<dynamic> blockedByRecipient =
          recipientDoc.data()?['blockedUsers'] ?? [];

      if (blockedByRecipient.contains(_currentUserUid)) {
        emit(FriendRequestStateChanged(isFriendRequestSent: false));
        return;
      }

      await _firestore.collection(AuthString.fSUsers).doc(recipientUid).update({
        'friendRequestsReceived': FieldValue.arrayUnion([_currentUserUid]),
      });
      await _firestore
          .collection(AuthString.fSUsers)
          .doc(_currentUserUid)
          .update({
            'friendRequestsSent': FieldValue.arrayUnion([recipientUid]),
          });

      // إرسال إشعار
      final receiverFcmToken = recipientDoc.data()?['fcmToken'];
      if (receiverFcmToken != null) {
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'sendFriendRequestNotification',
        );
        await callable.call(<String, dynamic>{
          'receiverFcmToken': receiverFcmToken,
          'senderName': user.currentUserInfo?.name ?? 'مستخدم',
        });
      }
      emit(FriendRequestStateChanged(isFriendRequestSent: true));
    } catch (e) {
      emit(ChatFailure("Failed to add friend: $e"));
    }
  }

  // ---------------------------------------------------------------------------
  // 6. Video Call
  // ---------------------------------------------------------------------------
  Future<void> sendVideoCall({
    required String uid,
    required String userName,
    required String userImage,
  }) async {
    emit(ChatLoading());
    try {
      // 1. جلب بيانات المستقبل (Token)
      final receiverDoc = await _firestore
          .collection(AuthString.fSUsers)
          .doc(uid)
          .get();

      final receiverData = receiverDoc.data();
      // تأكد من أن البيانات ليست null قبل الوصول للمفتاح
      final receiverFcmToken = (receiverData)?['fcmToken'];

      if (receiverFcmToken != null) {
        // 2. إنشاء مستند المكالمة
        final callDoc = _firestore.collection('calls').doc();
        final callId = callDoc.id;

        await callDoc.set({
          'callerId': user.currentUserInfo?.userId ?? '',
          'callerName': user.currentUserInfo?.name ?? '',
          'callerImage': user.currentUserInfo?.image ?? '',
          'receiverId': uid,
          'receiverName': userName,
          'receiverImage': userImage,
          'channelName': callId,
          'isVideoCall': true,
          'status': 'ringing',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 3. استدعاء Cloud Function للإشعار (تم التعديل هنا)
        try {
          final HttpsCallable callable = FirebaseFunctions.instance
              .httpsCallable('sendNotification');

          await callable.call(<String, dynamic>{
            'receiverFcmToken': receiverFcmToken,
            'type': 'Call', // نوع مخصص للمكالمات ليقوم التطبيق بفتح شاشة الرنين
            'senderName': user.currentUserInfo?.name ?? 'مستخدم',
            'senderImage': user.currentUserInfo?.image ?? '',
            'messageContent': 'Incoming Video Call', // نص الإشعار
            'callId': callId, // معرف المكالمة (مهم جداً للربط)
            'senderId': user.currentUserInfo?.userId ?? '',
            'isVideoCall': true,
          });
        } catch (e) {
          print("Failed to send call notification: $e");
          // لن نوقف العملية هنا، لأن المستند تم إنشاؤه، لكن من الجيد معرفة الخطأ
        }

        emit(NavChatCall());
      } else {
        emit(ChatFailure("User cannot be reached right now (No Token)."));
      }
    } catch (e) {
      emit(ChatFailure("Call failed: $e"));
    }
  }
  // ---------------------------------------------------------------------------
  // Utility Functions (No State Emitted usually, or handled internally)
  // ---------------------------------------------------------------------------

  void markMessagesAsRead(String uid) {
    // هذه العملية صامتة لا تحتاج لـ Loading/Success لتعطيل الواجهة
    _firestore
        .collection('chat')
        .doc(chatRoomId(uid))
        .update({'unreadCount.$_currentUserUid': 0})
        .catchError((e) => print("Error marking read: $e"));
  }

  Future<void> editMessageText({
    required String newText,
    required String messageId,
    required String uId,
  }) async {
    if (newText.trim().isEmpty) return;

    try {
      await _firestore
          .collection('chat')
          .doc(chatRoomId(uId))
          .collection('message')
          .doc(messageId)
          .update({'message': newText.trim(), 'isEdited': true});
      // يمكن إضافة emit إذا أردت إغلاق نافذة التعديل
    } catch (e) {
      print("Error editing message: $e");
    }
  }

  Future<void> deleteMessage({
    required String messageId,
    required String uId,
  }) async {
    try {
      await _firestore
          .collection('chat')
          .doc(chatRoomId(uId))
          .collection('message')
          .doc(messageId)
          .delete();
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  Stream<QuerySnapshot> getMessageStream({
    required bool isGroupChat,
    required String chatId,
  }) {
    final path = isGroupChat
        ? _firestore.collection('groups').doc(chatId).collection('messages')
        : _firestore.collection('chat').doc(chatId).collection('message');

    return path.orderBy('date', descending: false).snapshots();
  }

  // ---------------------------------------------------------------------------
  // 2. Send Image (Multi-Image)
  // ---------------------------------------------------------------------------
  Future<void> sendImage({
    required bool isGroupChat, // <--- جديد
    required String chatId, // <--- جديد (Group ID or Room ID)
    required String uid, // Receiver ID (للإشعارات فقط)
    required String userName, // (للبيانات فقط)
    required String userImage, // (للبيانات فقط)
    List<XFile>? preSelectedImages,
    String? caption,
  }) async {
    // تحديد المسار بناءً على نوع المحادثة
    final collectionPath = isGroupChat ? 'groups' : 'chat';
    final messageSubCollection = isGroupChat ? 'messages' : 'message';

    List<XFile> imagesToUpload = preSelectedImages ?? [];
    if (imagesToUpload.isEmpty) {
      imagesToUpload = await upload.pickMultipleImages();
    }

    if (imagesToUpload.isEmpty) return;

    emit(ChatLoading());

    try {
      List<String> imageUrls = await upload.uploadMultipleImagesAndGetUrls(
        imagesToUpload,
      );
      final uuid = const Uuid().v4();

      // 1. إذا كانت محادثة فردية، ننشئ/نحدث الغرفة (في المجموعات الغرفة موجودة)
      if (!isGroupChat) {
        await _firestore.collection('chat').doc(chatId).set({
          'senderName': user.currentUserInfo?.name ?? '',
          'senderImage': user.currentUserInfo?.image ?? '',
          'senderId': user.currentUserInfo?.userId ?? '',
          'receiverName': userName,
          'receiverImage': userImage,
          'receiverId': uid,
          'partial': [user.currentUserInfo?.userId ?? '', uid],
          'chatRoomId': chatId,
          'date': Timestamp.now(),
        }, SetOptions(merge: true));
      }

      // 2. إرسال الرسالة
      final messageData = MessageModel(
        messageId: uuid,
        senderId: user.currentUserInfo?.userId ?? '',
        senderName: user.currentUserInfo?.name ?? '',
        senderImage: user.currentUserInfo?.image ?? '',
        date: Timestamp.now(),
        type: 'image',
        imageUrls: imageUrls,
        message: caption ?? '',
        status: 'sent',
      ).toMap();

      await _firestore
          .collection(collectionPath) // <--- استخدام المسار الديناميكي
          .doc(chatId)
          .collection(messageSubCollection) // <--- استخدام المسار الديناميكي
          .doc(uuid)
          .set(messageData);

      // 3. تحديث آخر رسالة
      Map<String, dynamic> updateData = {
        'lastMessage': '📷 صورة',
        'date': Timestamp.now(),
      };

      if (isGroupChat) {
        updateData['lastMessageTimestamp'] = Timestamp.now();
      } else {
        updateData['unreadCount.$uid'] = FieldValue.increment(1);
      }

      await _firestore
          .collection(collectionPath)
          .doc(chatId)
          .update(updateData);

      // 4. الإشعار
      // في المجموعات، منطق الإشعارات يختلف (يجب إرساله لكل الأعضاء)،
      // لكن كحل مؤقت سنرسله لـ uid الممرر إذا كان فردياً.
      if (!isGroupChat) {
        await notifiMessage(
          typeMessage: 'Image',
          message: 'Sent an image',
          uid: uid,
          chatId: chatId,
        );
      }

      emit(ChatSuccess());
    } catch (e) {
      emit(ChatFailure('Failed to send image: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Send Video
  // ---------------------------------------------------------------------------
  Future<void> sendVideo({
    required String uid,
    required bool isGroupChat,
    required String
    chatId, // تأكد عند الاستدعاء أن تمرر هنا الـ RoomID للفردي أو GroupID للمجموعة
    required String userName,
    required String userImage,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? videoFile = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (videoFile == null) return;

    // تحديد المسار بناءً على نوع المحادثة
    final collectionPath = isGroupChat ? 'groups' : 'chat';
    final messageSubCollection = isGroupChat ? 'messages' : 'message';

    emit(ChatLoading());

    try {
      // رفع الفيديو
      final fileId = const Uuid().v4();
      final ref = FirebaseStorage.instance
          .ref()
          .child('video_messages')
          .child('$fileId.mp4');

      await ref.putFile(File(videoFile.path));
      final videoUrl = await ref.getDownloadURL();

      final messageId = const Uuid().v4();

      // 1. إعداد الغرفة للمحادثات الفردية فقط
      if (!isGroupChat) {
        await _firestore.collection('chat').doc(chatId).set({
          'senderName': user.currentUserInfo?.name ?? '',
          'senderImage': user.currentUserInfo?.image ?? '',
          'senderId': user.currentUserInfo?.userId ?? '',
          'receiverName': userName,
          'receiverImage': userImage,
          'receiverId': uid,
          'partial': [user.currentUserInfo?.userId ?? '', uid],
          'chatRoomId': chatId,
          'date': Timestamp.now(),
        }, SetOptions(merge: true));
      }

      // 2. إعداد بيانات الرسالة
      final messageData = MessageModel(
        messageId: messageId,
        senderId: user.currentUserInfo?.userId ?? '',
        senderName: user.currentUserInfo?.name ?? '',
        senderImage: user.currentUserInfo?.image ?? '',
        date: Timestamp.now(),
        type: 'video',
        videoUrl: videoUrl,
        fileName: videoFile.name,
        status: 'sent',
      ).toMap();

      // 3. إضافة الرسالة (تم تصحيح الخطأ هنا باستخدام chatId)
      await _firestore
          .collection(collectionPath)
          .doc(chatId)
          .collection(messageSubCollection)
          .doc(messageId)
          .set(messageData);

      // 4. تحديث آخر رسالة والعدادات
      Map<String, dynamic> updateData = {
        'lastMessage': '🎥 فيديو',
        'date': Timestamp.now(),
      };

      if (isGroupChat) {
        updateData['lastMessageTimestamp'] = Timestamp.now();
      } else {
        // زيادة العداد فقط في المحادثات الفردية (أو معالجة خاصة للجروبات)
        updateData['unreadCount.$uid'] = FieldValue.increment(1);
      }

      await _firestore
          .collection(collectionPath)
          .doc(chatId)
          .update(updateData);

      // 5. الإشعار
      if (!isGroupChat) {
        await notifiMessage(
          typeMessage: 'Video',
          message: 'Sent a video',
          uid: uid,
          chatId: chatId,
        );
      }
      emit(ChatSuccess());
    } catch (e) {
      emit(ChatFailure('Failed to send video: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Send File
  // ---------------------------------------------------------------------------
  Future<void> sendFile({
    required String uid,
    required bool isGroupChat,
    required String chatId,
    required String userName,
    required String userImage,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    // تحديد المسار بناءً على نوع المحادثة
    final collectionPath = isGroupChat ? 'groups' : 'chat';
    final messageSubCollection = isGroupChat ? 'messages' : 'message';

    emit(ChatLoading());

    try {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      // رفع الملف
      final ref = FirebaseStorage.instance
          .ref()
          .child('file_messages')
          .child('${const Uuid().v4()}_$fileName');

      await ref.putFile(file);
      final fileUrl = await ref.getDownloadURL();

      final messageId = const Uuid().v4();

      // 1. إعداد الغرفة للمحادثات الفردية فقط
      if (!isGroupChat) {
        await _firestore.collection('chat').doc(chatId).set({
          'senderName': user.currentUserInfo?.name ?? '',
          'senderImage': user.currentUserInfo?.image ?? '',
          'senderId': user.currentUserInfo?.userId ?? '',
          'receiverName': userName,
          'receiverImage': userImage,
          'receiverId': uid,
          'partial': [user.currentUserInfo?.userId ?? '', uid],
          'chatRoomId': chatId,
          'date': Timestamp.now(),
        }, SetOptions(merge: true));
      }

      // 2. بيانات الرسالة
      final messageData = MessageModel(
        messageId: messageId,
        senderId: user.currentUserInfo?.userId ?? '',
        senderName: user.currentUserInfo?.name ?? '',
        senderImage: user.currentUserInfo?.image ?? '',
        date: Timestamp.now(),
        type: 'file',
        fileUrl: fileUrl,
        fileName: fileName,
        status: 'sent',
      ).toMap();

      // 3. إضافة الرسالة
      await _firestore
          .collection(collectionPath)
          .doc(chatId)
          .collection(messageSubCollection)
          .doc(messageId)
          .set(messageData);

      // 4. تحديث آخر رسالة
      Map<String, dynamic> updateData = {
        'lastMessage': '📄 ملف: $fileName',
        'date': Timestamp.now(),
      };

      if (isGroupChat) {
        updateData['lastMessageTimestamp'] = Timestamp.now();
      } else {
        updateData['unreadCount.$uid'] = FieldValue.increment(1);
      }

      await _firestore
          .collection(collectionPath)
          .doc(chatId)
          .update(updateData);

      // 5. الإشعار
      if (!isGroupChat) {
        await notifiMessage(
          typeMessage: 'File',
          message: 'Sent a file',
          uid: uid,
          chatId: chatId,
        );
      }

      emit(ChatSuccess());
    } catch (e) {
      emit(ChatFailure('Failed to send file: $e'));
    }
  }
  // ---------------------------------------------------------------------------
  // دالة المساعدة لإرسال الإشعار
  //---------------------------------------------------------------------------

  Future<void> notifiMessage({
    required String typeMessage,
    required String message,
    required String uid,
    required String chatId,
  }) async {
    try {
      final receiverDoc = await _firestore
          .collection(AuthString.fSUsers)
          .doc(uid)
          .get();
      final receiverFcmToken = receiverDoc.data()?['fcmToken'];

      if (receiverFcmToken != null) {
        final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'sendNotification',
        );
        await callable.call(<String, dynamic>{
          'receiverFcmToken': receiverFcmToken,
          'type': typeMessage,
          'senderName': user.currentUserInfo?.name ?? 'مستخدم',
          'senderImage': user.currentUserInfo?.image ?? '',
          'messageContent': message,
          'chatRoomId': chatId,
          'senderId': user.currentUserInfo?.userId ?? '',
        });
      }
    } catch (e) {
      print("Notification error: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // 7. Block User
  // ---------------------------------------------------------------------------
  Future<void> blockUser(String userToBlockUid) async {
    emit(ChatLoading());
    try {
      final batch = _firestore.batch();

      // إزالة من الطلبات
      batch.update(_firestore.collection('users').doc(_currentUserUid), {
        'friendRequestsReceived': FieldValue.arrayRemove([userToBlockUid]),
      });
      batch.update(_firestore.collection('users').doc(userToBlockUid), {
        'friendRequestsSent': FieldValue.arrayRemove([_currentUserUid]),
      });

      // إضافة للحظر
      batch.update(_firestore.collection('users').doc(_currentUserUid), {
        'blockedUsers': FieldValue.arrayUnion([userToBlockUid]),
      });
      batch.update(_firestore.collection('users').doc(userToBlockUid), {
        'blockedBy': FieldValue.arrayUnion([_currentUserUid]),
      });

      await batch.commit();
      emit(UserBlockedStateChanged(isUserBlocked: true));
    } catch (e) {
      emit(ChatFailure("Failed to block user: $e"));
    }
  }

  // ---------------------------------------------------------------------------
  // 8. Friend Requests (Send, Accept, Reject)
  // ---------------------------------------------------------------------------

  Future<void> sendFriendRequest(String recipientUid) async {
    // لا نحتاج لـ Loading هنا عادةً لتجربة مستخدم أسرع، لكن يمكن إضافته
    // emit(ChatLoading());

    try {
      // أ) التحقق من الحظر
      final recipientDoc = await _firestore
          .collection(AuthString.fSUsers)
          .doc(recipientUid)
          .get();
      final List<dynamic> blockedByRecipient =
          recipientDoc.data()?['blockedUsers'] ?? [];

      if (blockedByRecipient.contains(_currentUserUid)) {
        emit(FriendRequestStateChanged(isFriendRequestSent: false));
        return;
      }

      // ب) تحديث قاعدة البيانات
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection(AuthString.fSUsers).doc(recipientUid),
        {
          'friendRequestsReceived': FieldValue.arrayUnion([_currentUserUid]),
        },
      );

      batch.update(
        _firestore.collection(AuthString.fSUsers).doc(_currentUserUid),
        {
          'friendRequestsSent': FieldValue.arrayUnion([recipientUid]),
        },
      );

      await batch.commit();

      // ج) إرسال الإشعار
      // ملاحظة: قمت بنقل منطق الإشعار داخل try لضمان عدم توقف الكود لو فشل الإشعار فقط
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

      emit(FriendRequestStateChanged(isFriendRequestSent: true));
    } catch (e) {
      print("Failed to send friend request: $e");
      emit(ChatFailure("Failed to send request"));
    }
  }

  Future<void> acceptFriendRequest(String senderUid) async {
    emit(ChatLoading()); // إظهار تحميل أثناء المعالجة
    try {
      final batch = _firestore.batch();

      // إضافة للأصدقاء
      batch.update(
        _firestore.collection(AuthString.fSUsers).doc(_currentUserUid),
        {
          'friends': FieldValue.arrayUnion([senderUid]),
        },
      );
      batch.update(_firestore.collection(AuthString.fSUsers).doc(senderUid), {
        'friends': FieldValue.arrayUnion([_currentUserUid]),
      });

      // إزالة من الطلبات
      batch.update(
        _firestore.collection(AuthString.fSUsers).doc(_currentUserUid),
        {
          'friendRequestsReceived': FieldValue.arrayRemove([senderUid]),
        },
      );
      batch.update(_firestore.collection(AuthString.fSUsers).doc(senderUid), {
        'friendRequestsSent': FieldValue.arrayRemove([_currentUserUid]),
      });

      await batch.commit();
      emit(ChatSuccess()); // لإعادة بناء الواجهة وإخفاء الطلب
    } catch (e) {
      emit(ChatFailure("Failed to accept request: $e"));
    }
  }

  Future<void> rejectFriendRequest(String senderUid) async {
    // يمكن عدم استخدام Loading هنا لإخفاء العنصر فوراً (Optimistic UI)
    // لكن للأمان سنستخدمه
    emit(ChatLoading());
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection(AuthString.fSUsers).doc(_currentUserUid),
        {
          'friendRequestsReceived': FieldValue.arrayRemove([senderUid]),
        },
      );
      batch.update(_firestore.collection(AuthString.fSUsers).doc(senderUid), {
        'friendRequestsSent': FieldValue.arrayRemove([_currentUserUid]),
      });

      await batch.commit();
      emit(ChatSuccess());
    } catch (e) {
      emit(ChatFailure("Failed to reject request: $e"));
    }
  }

  // ---------------------------------------------------------------------------
  // 9. Create Group
  // ---------------------------------------------------------------------------

  Future<void> createGroup({
    required String groupName,
    required List<String> selectedMemberIds,
  }) async {
    if (groupName.trim().isEmpty || selectedMemberIds.isEmpty) {
      emit(ChatFailure('Please enter a group name and select members.'));
      return;
    }

    emit(ChatLoading());

    try {
      final members = [_currentUserUid, ...selectedMemberIds];

      // إعداد بيانات المجموعة
      await _firestore.collection('groups').add({
        'groupName': groupName.trim(),
        'groupImage': '', // يمكن توسيع هذا لاحقاً لرفع صورة
        'createdBy': _currentUserUid,
        'createdAt': Timestamp.now(),
        'admins': [_currentUserUid],
        'members': members,
        'lastMessage': 'تم إنشاء المجموعة',
        'lastMessageTimestamp': Timestamp.now(),
        'lastMessageSenderName': 'النظام',
        'unreadCount': {for (var member in members) member: 0},
      });

      emit(NavChat()); // الانتقال لشاشة الشات أو القائمة
    } catch (e) {
      emit(ChatFailure('Failed to create group: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // 10. Random Match (Find Trip)
  // ---------------------------------------------------------------------------
  // دالة حساب ChatRoomId (نفس الموجودة في MapScreen)
  String getChatRoomId(String user1, String user2) {
    List<String> userIds = [user1, user2];
    userIds.sort();
    return '${userIds[0]}_${userIds[1]}';
  }

  Future<void> findNewTrip() async {
    // 1. تغيير الحالة للتحميل (بدل setState)
    emit(FindTripLoading());

    if (user.currentUserInfo == null) {
      emit(ChatFailure("User info not loaded"));
      return;
    }

    try {
      final usersRef = _firestore.collection(AuthString.fSUsers);
      final randomId = usersRef.doc().id;

      // محاولة البحث عن مستخدم ID الخاص به أكبر من Random ID
      QuerySnapshot querySnapshot = await usersRef
          .where('isOnline', isEqualTo: true)
          .where(FieldPath.documentId, isNotEqualTo: _currentUserUid)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: randomId)
          .limit(1)
          .get();

      // إذا لم نجد، نبحث عن مستخدم ID الخاص به أصغر (Fallback)
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await usersRef
            .where('isOnline', isEqualTo: true)
            .where(FieldPath.documentId, isNotEqualTo: _currentUserUid)
            .where(FieldPath.documentId, isLessThan: randomId)
            .limit(1)
            .get();
      }

      DocumentSnapshot? userDoc = querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.first
          : null;

      if (userDoc != null) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // التحقق من وجود الموقع
        if (userData['latitude'] != null && userData['longitude'] != null) {
          final position = LatLng(userData['latitude'], userData['longitude']);

          final matchedUser = MatchedUser(
            uid: userDoc.id,
            name: userData['name'] ?? 'مستخدم',
            image: userData['image'] ?? '',
            country: userData['userCountry'] ?? 'غير معروف',
            position: position,
          );

          // إرسال البيانات للواجهة
          emit(TripFoundState(matchedUser));
        } else {
          // المستخدم ليس لديه موقع، جرب مرة أخرى (Recursion)
          // ملاحظة: يجب الحذر هنا من التكرار اللانهائي، يفضل وضع حد للمحاولات
          await findNewTrip();
        }
      } else {
        emit(TripNotFoundState());
      }
    } catch (e) {
      emit(ChatFailure('Error finding user: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // 11. Audio Recording & Sending
  // ---------------------------------------------------------------------------

  Future<void> startRecording() async {
    try {
      // طلب الإذن
      var status = await Permission.microphone.request();

      if (status.isGranted) {
        final appDocumentsDir = await getApplicationDocumentsDirectory();
        _audioPath = '${appDocumentsDir.path}/${const Uuid().v4()}.m4a';

        // التأكد من أن المسار صالح
        await _audioRecorder.start(const RecordConfig(), path: _audioPath!);

        isRecording = true;
        // تحديث حالة الزر في الواجهة
        emit(RecordingStateChanged(isRecording));
      } else {
        emit(ChatFailure("تم رفض إذن الميكروفون"));
      }
    } catch (e) {
      isRecording = false;
      emit(RecordingStateChanged(isRecording));
      emit(ChatFailure('Failed to start recording: $e'));
    }
  }

  // 3. وظيفة لإيقاف التسجيل ورفع الملف وإرسال الرسالة
  Future<void> stopRecordingAndSend({
    required String chatRoomId,
    required String receiverId, // مهم لتحديث العداد
  }) async {
    if (!isRecording) return;

    try {
      final path = await _audioRecorder.stop();
      isRecording = false;
      emit(RecordingStateChanged(isRecording)); // تحديث الأيقونة للتوقف

      if (path != null) {
        emit(ChatLoading()); // إظهار لودينج أثناء الرفع

        final audioFile = File(path);

        // 1. رفع الملف
        final fileId = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('audio_messages')
            .child('$fileId.m4a');

        await ref.putFile(audioFile);
        final audioUrl = await ref.getDownloadURL();

        // 2. حساب المدة
        final player = AudioPlayer();
        final duration = await player.setFilePath(path);
        player.dispose();

        final messageId = const Uuid().v4();

        // 3. إنشاء الموديل (للتوحيد مع الجزء الأول)
        // ملاحظة: هنا سنحتاج لإضافة حقل duration لـ MessageModel أو إرساله كـ Map إذا لم يكن موجوداً
        final messageData = {
          'type': 'audio',
          'senderId': user.currentUserInfo?.userId ?? '',
          'senderName': user.currentUserInfo?.name ?? '',
          'senderImage': user.currentUserInfo?.image ?? '',
          'date': Timestamp.now(),
          'audioUrl': audioUrl,
          'duration': duration?.inMilliseconds ?? 0,
          'messageId': messageId,
          'status': 'sent',
        };

        // 4. الحفظ في Firestore
        await _firestore
            .collection('chat')
            .doc(chatRoomId)
            .collection('message')
            .doc(messageId)
            .set(messageData);

        // 5. تحديث آخر رسالة
        await _firestore.collection('chat').doc(chatRoomId).update({
          'lastMessage': '🎤 تسجيل صوتي',
          'date': Timestamp.now(),
          'unreadCount.$receiverId': FieldValue.increment(1),
        });

        // 6. إرسال إشعار
        await notifiMessage(
          typeMessage: 'Audio',
          message: 'Sent an audio message',
          uid: receiverId,
          chatId: chatRoomId,
        );

        emit(ChatSuccess());
      }
    } catch (e) {
      emit(ChatFailure('Failed to send audio: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // 12. Message Status (Delivered & Seen)
  // ---------------------------------------------------------------------------

  /// يتم استدعاء هذه الدالة عندما يتم تحميل قائمة المحادثات أو استلام إشعار في الخلفية
  Future<void> markMessagesAsDelivered({
    required String chatId,
    required bool isGroupChat,
  }) async {
    // Delivered عادةً منطقية في المحادثات الفردية أكثر، لكن سأضعها لتعمل في الحالتين
    final collectionPath = isGroupChat ? 'groups' : 'chat';
    final messageSubCollection = isGroupChat ? 'messages' : 'message';

    try {
      // جلب الرسائل التي:
      // 1. ليست مرسلة مني (أنا المستقبل)
      // 2. حالتها "sent" فقط (لم تصبح delivered أو seen بعد)
      final querySnapshot = await _firestore
          .collection(collectionPath)
          .doc(chatId)
          .collection(messageSubCollection)
          .where('senderId', isNotEqualTo: _currentUserUid)
          .where('status', isEqualTo: 'sent')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();

        for (var doc in querySnapshot.docs) {
          batch.update(doc.reference, {'status': 'delivered'});
        }

        await batch.commit();
        // لا نحتاج لـ emit هنا لأن التغيير سيظهر تلقائياً عبر الـ Stream في الواجهة
      }
    } catch (e) {
      print("Error marking messages as delivered: $e");
    }
  }

  /// يتم استدعاء هذه الدالة عندما يفتح المستخدم شاشة المحادثة (UI)
  Future<void> markMessagesAsSeen({
    required String chatId,
    required bool isGroupChat,
  }) async {
    final collectionPath = isGroupChat ? 'groups' : 'chat';
    final messageSubCollection = isGroupChat ? 'messages' : 'message';

    try {
      if (isGroupChat) {
        // --- منطق المجموعات (Array) ---
        // نبحث عن الرسائل التي لم أرسلها أنا، ولم يتم إضافة الـ ID الخاص بي لقائمة المشاهدين بعد
        final querySnapshot = await _firestore
            .collection(collectionPath)
            .doc(chatId)
            .collection(messageSubCollection)
            .where('senderId', isNotEqualTo: _currentUserUid)
            .get();
        // ملاحظة: Firestore لا يدعم الاستعلام بـ "لا يحتوي على في مصفوفة" مباشرة بسهولة
        // لذا سنجلب الرسائل الحديثة ونتحقق يدوياً أو نعتمد على الفلترة في التطبيق،
        // ولكن للأداء الأفضل سنقوم بتحديث الكل بـ arrayUnion (التي لا تكرر القيم)

        final batch = _firestore.batch();
        bool hasUpdates = false;

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          final List<dynamic> seenBy = data['seenBy'] ?? [];

          // إذا لم يكن الـ ID الخاص بي موجوداً في القائمة، قم بتحديث المستند
          if (!seenBy.contains(_currentUserUid)) {
            batch.update(doc.reference, {
              'seenBy': FieldValue.arrayUnion([_currentUserUid]),
              // خياري: يمكنك تحديث الحالة لـ seen إذا أردت، لكن الاعتماد على القائمة أدق
            });
            hasUpdates = true;
          }
        }

        // تصفير العداد للمجموعات
        batch.update(_firestore.collection('groups').doc(chatId), {
          'unreadCount.$_currentUserUid': 0,
        });

        if (hasUpdates) await batch.commit();
      } else {
        // --- منطق المحادثة الفردية (Status String) ---
        final querySnapshot = await _firestore
            .collection(collectionPath)
            .doc(chatId)
            .collection(messageSubCollection)
            .where('senderId', isNotEqualTo: _currentUserUid)
            .where('status', isNotEqualTo: 'seen')
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (var doc in querySnapshot.docs) {
            batch.update(doc.reference, {'status': 'seen'});
          }
          // تصفير العداد للفردي
          batch.update(_firestore.collection('chat').doc(chatId), {
            'unreadCount.$_currentUserUid': 0,
          });
          await batch.commit();
        }
      }
    } catch (e) {
      print("Error marking messages as seen: $e");
    }
  }
}
