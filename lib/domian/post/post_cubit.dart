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

  void commentOnPost(String postId, String uId, String text) {
    // 1. إضافة التعليق في قاعدة البيانات
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
          // 2. تحديث العداد في قاعدة البيانات
          FirebaseFirestore.instance.collection('posts').doc(postId).update({
            'commentsCount': FieldValue.increment(1),
          });

          // نبحث عن المنشور داخل القائمة المحلية ونزيد العداد يدوياً
          try {
            // نجد المنشور
            var post = posts.firstWhere((element) => element.postId == postId);

            // نزيد العداد
            post.commentsCount = (post.commentsCount ?? 0) + 1;

            // نقوم بعمل emit لكي يعيد الـ BlocBuilder بناء الواجهة بالرقم الجديد
            if (!isClosed) emit(GetPostsSuccessState());
          } catch (e) {
            print("Post not found locally");
          }
        })
        .catchError((error) {
          print(error.toString());
        });
  }

  void deletePost(PostModel post) {
    // 1. تحديد ما إذا كان هناك ملف (صورة أو فيديو) لحذفه
    String? mediaUrl;
    if (post.postImage != null && post.postImage!.isNotEmpty) {
      mediaUrl = post.postImage;
    } else if (post.postVideo != null && post.postVideo!.isNotEmpty) {
      mediaUrl = post.postVideo;
    }

    // دالة داخلية للحذف من Firestore (لتجنب تكرار الكود)
    void deleteFromFirestore() {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(post.postId)
          .delete()
          .then((value) {
            // حذف محلي من القائمة
            posts.removeWhere((element) => element.postId == post.postId);
            if (!isClosed) emit(GetPostsSuccessState());
          })
          .catchError((error) {});
    }

    // 2. التنفيذ
    if (mediaUrl != null) {
      // أ. إذا كان هناك ميديا، نحذفها من الستوريج أولاً
      firebase_storage.FirebaseStorage.instance
          .refFromURL(mediaUrl)
          .delete()
          .then((_) {
            // ب. بعد نجاح حذف الملف، نحذف البيانات
            deleteFromFirestore();
          })
          .catchError((error) {
            // حتى لو فشل حذف الصورة (مثلاً حذفت يدوياً)، نحذف البيانات
            deleteFromFirestore();
            print("Error deleting file: $error");
          });
    } else {
      // ج. إذا كان نصاً فقط، نحذف البيانات مباشرة
      deleteFromFirestore();
    }
  }
}
