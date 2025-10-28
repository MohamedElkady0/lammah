import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'image_upload_state.dart';

class ImageUploadCubit extends Cubit<ImageUploadState> {
  ImageUploadCubit() : super(ImageUploadInitial());

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadImages(List<ImageFile> images) async {
    if (images.isEmpty) return;

    emit(ImageUploadLoading());

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

      emit(ImageUploadSuccess(downloadUrls));
    } catch (e) {
      emit(ImageUploadFailure('حدث خطأ أثناء رفع الصور: ${e.toString()}'));
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
}
