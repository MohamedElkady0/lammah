import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  // 3. إنشاء منشور جديد (مثال سريع)
  void createPost({
    required String uId,
    required String name,
    required String userImage,
    required String text,
    String? postImage,
  }) {
    emit(CreatePostLoadingState());

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
          // تحديث الـ ID داخل الوثيقة
          value.update({'postId': value.id});
          emit(CreatePostSuccessState());
          getPosts(); // تحديث القائمة
        })
        .catchError((error) {
          emit(CreatePostErrorState(error.toString()));
        });
  }
}
