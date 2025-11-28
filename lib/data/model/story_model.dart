class StoryModel {
  String? storyId;
  String? uId; // معرف صاحب القصة
  String? name; // اسم صاحب القصة (للسرعة في العرض)
  String? userImage; // صورة صاحب القصة
  String? mediaUrl; // رابط الصورة أو الفيديو
  String? mediaType; // 'image' or 'video'
  String? caption; // نص اختياري
  String? dateTime; // وقت النشر
  List<String>? likes; // قائمة بمعرفات من قاموا بالإعجاب
  List<String>? views;

  // التعليقات يفضل أن تكون في Sub-collection منفصلة في فايربيس
  // لتقليل حجم الوثيقة، لذا لن نضعها كقائمة هنا.

  StoryModel({
    this.storyId,
    this.uId,
    this.name,
    this.userImage,
    this.mediaUrl,
    this.mediaType,
    this.caption,
    this.dateTime,
    this.likes,
    this.views,
  });

  StoryModel.fromJson(Map<String, dynamic> json) {
    storyId = json['storyId'];
    uId = json['uId'];
    name = json['name'];
    userImage = json['userImage'];
    mediaUrl = json['mediaUrl'];
    mediaType = json['mediaType'];
    caption = json['caption'];
    dateTime = json['dateTime'];
    likes = json['likes'] != null ? List<String>.from(json['likes']) : [];
    views = json['views'] != null ? List<String>.from(json['views']) : [];
  }

  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'uId': uId,
      'name': name,
      'userImage': userImage,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'dateTime': dateTime,
      'likes': likes ?? [],
      'views': views ?? [],
    };
  }
}
