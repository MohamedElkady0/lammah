import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
}
