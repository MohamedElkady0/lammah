import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'upload_state.dart';

class UploadCubit extends Cubit<UploadState> {
  UploadCubit() : super(UploadInitial());

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. أضف متغيرات جديدة لإدارة حالة التسجيل
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? _audioPath;

  Future<void> uploadImages(List<ImageFile> images) async {
    if (images.isEmpty) return;

    emit(UploadLoading());

    try {
      final List<String> downloadUrls = [];

      for (final imageFile in images) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}-${imageFile.name}';
        final ref = _storage.ref().child('uploads/$fileName');

        await ref.putFile(File(imageFile.path!));

        final url = await ref.getDownloadURL();
        downloadUrls.add(url);
      }

      emit(UploadSuccess(downloadUrls));
    } catch (e) {
      emit(UploadFailure('حدث خطأ أثناء رفع الصور: ${e.toString()}'));
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    // طلب إذن الوصول إلى الصور
    var status = await Permission.photos.request();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      return images;
    } else {
      // يمكنك هنا عرض رسالة للمستخدم تفيد برفض الإذن
      print('Photo library permission denied.');
      return [];
    }
  }

  // 2. وظيفة لرفع قائمة من الصور إلى Firebase Storage وإرجاع روابطها
  Future<List<String>> uploadMultipleImagesAndGetUrls(
    List<XFile> images,
  ) async {
    List<String> downloadUrls = [];
    final storageRef = FirebaseStorage.instance.ref();

    // استخدام Future.wait لرفع جميع الصور بالتوازي لتحسين الأداء
    await Future.wait(
      images.map((image) async {
        final imageId = const Uuid().v4();
        final imageRef = storageRef.child('chat_images/$imageId.jpg');

        // رفع الملف
        await imageRef.putFile(File(image.path));

        // الحصول على رابط التحميل
        final url = await imageRef.getDownloadURL();
        downloadUrls.add(url);
      }),
    );

    return downloadUrls;
  }

  // 2. وظيفة لبدء التسجيل
  Future<void> startRecording() async {
    try {
      // التحقق من إذن الميكروفون
      if (await _audioRecorder.hasPermission()) {
        // الحصول على مسار مؤقت لحفظ الملف
        final appDocumentsDir = await getApplicationDocumentsDirectory();
        _audioPath = '${appDocumentsDir.path}/${const Uuid().v4()}.m4a';

        // بدء التسجيل
        await _audioRecorder.start(const RecordConfig(), path: _audioPath!);

        isRecording = true;
        emit(
          RecordingStateChanged(isRecording),
        ); // إصدار حالة جديدة لإعلام الواجهة
      } else {
        emit(UploadFailure("يرجى منح إذن استخدام الميكروفون"));
      }
    } catch (e) {
      debugPrint("Error starting recording: $e");
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
      }
    } catch (e) {
      debugPrint("Error stopping recording and sending: $e");
    }
  }
}
