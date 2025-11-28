class PostModel {
  String? postId;
  String? uId;
  String? name;
  String? userImage;
  String? dateTime;
  String? text; // نص المنشور
  String? postImage; // صورة المنشور (إن وجدت)
  String? postVideo; // فيديو المنشور (إن وجد)
  List<String>? likes; // قائمة المعجبين
  int? commentsCount; // عدد التعليقات (للعرض السريع)

  PostModel({
    this.postId,
    this.uId,
    this.name,
    this.userImage,
    this.dateTime,
    this.text,
    this.postImage,
    this.postVideo,
    this.likes,
    this.commentsCount,
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    uId = json['uId'];
    name = json['name'];
    userImage = json['userImage'];
    dateTime = json['dateTime'];
    text = json['text'];
    postImage = json['postImage'];
    postVideo = json['postVideo'];
    likes = json['likes'] != null ? List<String>.from(json['likes']) : [];
    commentsCount = json['commentsCount'] ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'uId': uId,
      'name': name,
      'userImage': userImage,
      'dateTime': dateTime,
      'text': text,
      'postImage': postImage,
      'postVideo': postVideo,
      'likes': likes ?? [],
      'commentsCount': commentsCount ?? 0,
    };
  }
}
