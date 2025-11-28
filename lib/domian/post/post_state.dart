part of 'post_cubit.dart';

abstract class PostStates {}

class PostInitialState extends PostStates {}

// جلب المنشورات
class GetPostsLoadingState extends PostStates {}

class GetPostsSuccessState extends PostStates {}

class GetPostsErrorState extends PostStates {
  final String error;
  GetPostsErrorState(this.error);
}

// التفاعل (اللايك)
class LikePostSuccessState extends PostStates {}

class LikePostErrorState extends PostStates {
  final String error;
  LikePostErrorState(this.error);
}

// إنشاء منشور
class CreatePostLoadingState extends PostStates {}

class CreatePostSuccessState extends PostStates {}

class CreatePostErrorState extends PostStates {
  final String error;
  CreatePostErrorState(this.error);
}
