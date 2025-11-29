import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart'
    as firebase_storage; // للستوريج
import 'package:lammah/data/model/post_model.dart';
part 'post_state.dart';

class PostCubit extends Cubit<PostStates> {
  PostCubit() : super(PostInitialState());

  static PostCubit get(context) => BlocProvider.of(context);

  List<PostModel> posts = [];
  List<String> postsIds = []; // لحفظ معرفات الوثائق للتعديل عليها

  // 1. جلب المنشورات (Timeline)
  void getPosts() {
    emit(GetPostsLoadingState());

    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('dateTime', descending: true)
        .get()
        .then((value) {
          posts = [];
          postsIds = [];
          for (var element in value.docs) {
            postsIds.add(element.id);
            posts.add(PostModel.fromJson(element.data()));
          }
          emit(GetPostsSuccessState());
        })
        .catchError((error) {
          emit(GetPostsErrorState(error.toString()));
        });
  }

  // 2. الإعجاب بالمنشور (Like Logic)
  void likePost(String postId, String userId) {
    // نجد المنشور محلياً لتحديث الواجهة فوراً (Optimistic UI Update)
    int index = posts.indexWhere((element) => element.postId == postId);
    if (index != -1) {
      PostModel localPost = posts[index];

      if (localPost.likes!.contains(userId)) {
        localPost.likes!.remove(userId); // إزالة محلياً
        // تحديث السيرفر: إزالة
        FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([userId]),
        });
      } else {
        localPost.likes!.add(userId); // إضافة محلياً
        // تحديث السيرفر: إضافة
        FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([userId]),
        });
      }

      // نرسل حالة نجاح ليقوم الـ BlocBuilder بإعادة بناء القطعة المتغيرة فقط
      emit(LikePostSuccessState());
    }
  }

  // دالة مساعدة لرفع الصورة
  void uploadPostImage({
    required String uId,
    required String name,
    required String userImage,
    required String text,
    required File imageFile,
  }) {
    // اسم الملف
    String fileName = Uri.file(imageFile.path).pathSegments.last;

    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('posts/$fileName') // المسار في الستوريج
        .putFile(imageFile)
        .then((value) {
          value.ref
              .getDownloadURL()
              .then((value) {
                // بعد الحصول على الرابط، نحفظ المنشور
                savePostData(
                  uId: uId,
                  name: name,
                  userImage: userImage,
                  text: text,
                  postImage: value, // نمرر الرابط هنا
                );
              })
              .catchError((error) {
                emit(CreatePostErrorState(error.toString()));
              });
        })
        .catchError((error) {
          emit(CreatePostErrorState(error.toString()));
        });
  }

  // دالة حفظ البيانات في Firestore (تستخدم للحالتين)
  void savePostData({
    required String uId,
    required String name,
    required String userImage,
    required String text,
    String? postImage,
    String? postVideo,
  }) {
    PostModel model = PostModel(
      uId: uId,
      name: name,
      userImage: userImage,
      dateTime: DateTime.now().toIso8601String(),
      text: text,
      postImage: postImage ?? '',
      likes: [],
      commentsCount: 0,
    );

    FirebaseFirestore.instance
        .collection('posts')
        .add(model.toMap())
        .then((value) {
          // تحديث الـ ID داخل الوثيقة لتسهيل الحذف لاحقاً
          value.update({'postId': value.id});
          emit(CreatePostSuccessState());
          getPosts(); // تحديث القائمة تلقائياً
        })
        .catchError((error) {
          emit(CreatePostErrorState(error.toString()));
        });
  }

  // 2. حذف المنشور
  void deletePost(String postId) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .delete()
        .then((value) {
          // حذف المنشور من القائمة المحلية لتحديث الواجهة فوراً
          posts.removeWhere((element) => element.postId == postId);
          emit(GetPostsSuccessState()); // إعادة بناء الواجهة
        })
        .catchError((error) {});
  }

  // تحديث دالة createPost لتقبل ملف فيديو
  void createPost({
    required String uId,
    required String name,
    required String userImage,
    required String text,
    File? postImageFile,
    File? postVideoFile, // <-- إضافة جديدة
  }) {
    emit(CreatePostLoadingState());

    if (postImageFile != null) {
      // رفع صورة
      uploadFile(
        uId: uId,
        name: name,
        userImage: userImage,
        text: text,
        file: postImageFile,
        isVideo: false,
      );
    } else if (postVideoFile != null) {
      // رفع فيديو
      uploadFile(
        uId: uId,
        name: name,
        userImage: userImage,
        text: text,
        file: postVideoFile,
        isVideo: true,
      );
    } else {
      // نص فقط
      savePostData(uId: uId, name: name, userImage: userImage, text: text);
    }
  }

  // دالة رفع عامة (General Upload Function)
  void uploadFile({
    required String uId,
    required String name,
    required String userImage,
    required String text,
    required File file,
    required bool isVideo,
  }) {
    String fileName = Uri.file(file.path).pathSegments.last;
    String path = isVideo ? 'posts/videos/$fileName' : 'posts/images/$fileName';

    firebase_storage.FirebaseStorage.instance
        .ref()
        .child(path)
        .putFile(file)
        .then((value) {
          value.ref
              .getDownloadURL()
              .then((value) {
                savePostData(
                  uId: uId,
                  name: name,
                  userImage: userImage,
                  text: text,
                  postImage: isVideo
                      ? null
                      : value, // إذا كان فيديو، الصورة null
                  postVideo: isVideo
                      ? value
                      : null, // إذا كان صورة، الفيديو null
                );
              })
              .catchError((error) {
                emit(CreatePostErrorState(error.toString()));
              });
        })
        .catchError((error) {
          emit(CreatePostErrorState(error.toString()));
        });
  }

  // إرسال تعليق
  void commentOnPost(String postId, String uId, String text) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
          'uId': uId,
          'text': text,
          'dateTime': DateTime.now().toIso8601String(),
        })
        .then((value) {
          // اختياري: تحديث عداد التعليقات في وثيقة المنشور الأصلية
          FirebaseFirestore.instance.collection('posts').doc(postId).update({
            'commentsCount': FieldValue.increment(1),
          });
        });
  }
}
