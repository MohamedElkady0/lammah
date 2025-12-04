import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/story_model.dart';
part 'story_state.dart';

class StoryCubit extends Cubit<StoryStates> {
  StoryCubit() : super(StoryInitialState());

  static StoryCubit get(context) => BlocProvider.of(context);

  // 1. اختيار ملف (صورة أو فيديو)
  File? storyMediaFile;
  String mediaType = ''; // 'image' or 'video'
  final ImagePicker picker = ImagePicker();

  Future<void> getStoryImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      storyMediaFile = File(pickedFile.path);
      mediaType = 'image';
      emit(StoryImagePickedSuccessState());
    } else {
      emit(StoryImagePickedErrorState());
    }
  }

  Future<void> getStoryVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      storyMediaFile = File(pickedFile.path);
      mediaType = 'video';
      emit(StoryVideoPickedSuccessState());
    } else {
      emit(StoryVideoPickedErrorState());
    }
  }

  // 2. رفع الوسائط وإنشاء القصة
  void uploadStory({
    required String uId,
    required String name,
    required String userImage,
    required String caption,
  }) {
    emit(CreateStoryLoadingState());

    String fileName = Uri.file(storyMediaFile!.path).pathSegments.last;

    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('stories/$uId/$fileName')
        .putFile(storyMediaFile!)
        .then((value) {
          value.ref
              .getDownloadURL()
              .then((value) {
                // بعد رفع الملف بنجاح، نقوم بإنشاء القصة في Firestore
                createStoryDoc(
                  uId: uId,
                  name: name,
                  userImage: userImage,
                  caption: caption,
                  mediaUrl: value,
                );
              })
              .catchError((error) {
                emit(CreateStoryErrorState(error.toString()));
              });
        })
        .catchError((error) {
          emit(CreateStoryErrorState(error.toString()));
        });
  }

  void createStoryDoc({
    required String uId,
    required String name,
    required String userImage,
    required String caption,
    required String mediaUrl,
  }) {
    // إنشاء كائن المودل
    StoryModel model = StoryModel(
      uId: uId,
      name: name,
      userImage: userImage,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      caption: caption,
      dateTime: DateTime.now().toIso8601String(),
      likes: [],
    );

    FirebaseFirestore.instance
        .collection('stories')
        .add(model.toMap()) // إضافة والحصول على ID تلقائي
        .then((value) {
          // تحديث الوثيقة لإضافة الـ ID بداخلها (اختياري ولكنه مفيد)
          value.update({'storyId': value.id});
          emit(CreateStorySuccessState());
          getStories(); // <--- استدعاء هذه الدالة لجلب البيانات الجديدة فوراً

          // إعادة تعيين المتغيرات
          storyMediaFile = null;
          mediaType = '';
        })
        .catchError((error) {
          emit(CreateStoryErrorState(error.toString()));
        });
  }

  // 3. جلب القصص (عرض القصص)
  List<StoryModel> stories = [];

  // استبدل قائمة stories القديمة بهذا الهيكل
  // المفتاح هو uId، والقيمة هي قائمة قصص هذا المستخدم
  Map<String, List<StoryModel>> groupedStories = {};

  void getStories() {
    emit(GetStoriesLoadingState());

    FirebaseFirestore.instance
        .collection('stories')
        .orderBy(
          'dateTime',
          descending: false,
        ) // ترتيب زمني من الأقدم للأحدث (داخل قصة المستخدم)
        .get()
        .then((value) {
          groupedStories = {}; // تصفير القائمة

          for (var element in value.docs) {
            // التحقق من مرور 24 ساعة
            DateTime storyTime = DateTime.parse(element.data()['dateTime']);
            if (DateTime.now().difference(storyTime).inHours < 24) {
              StoryModel model = StoryModel.fromJson(element.data());

              // منطق التجميع
              if (groupedStories.containsKey(model.uId)) {
                groupedStories[model.uId]!.add(model);
              } else {
                groupedStories[model.uId!] = [model];
              }
            }
          }
          emit(GetStoriesSuccessState());
        })
        .catchError((error) {
          emit(GetStoriesErrorState(error.toString()));
        });
  }

  // 4. حذف القصة (للمستخدم نفسه)
  void deleteStory(String storyId, String url) {
    // حذف من Firestore
    FirebaseFirestore.instance.collection('stories').doc(storyId).delete().then(
      (_) {
        // حذف من Storage
        firebase_storage.FirebaseStorage.instance.refFromURL(url).delete().then(
          (_) {
            getStories(); // تحديث القائمة
            emit(DeleteStorySuccessState());
          },
        );
      },
    );
  }

  // 5. الإعجاب بالقصة
  void likeStory(String storyId, String uId) {
    FirebaseFirestore.instance.collection('stories').doc(storyId).get().then((
      doc,
    ) {
      List likes = doc.data()?['likes'] ?? [];
      if (likes.contains(uId)) {
        // إذا كان معجباً بالفعل -> إزالة الإعجاب
        FirebaseFirestore.instance.collection('stories').doc(storyId).update({
          'likes': FieldValue.arrayRemove([uId]),
        });
      } else {
        // إضافة إعجاب
        FirebaseFirestore.instance.collection('stories').doc(storyId).update({
          'likes': FieldValue.arrayUnion([uId]),
        });
      }
      emit(LikeStorySuccessState());
    });
  }

  // 6. إضافة تعليق
  void commentOnStory(String storyId, String uId, String commentText) {
    FirebaseFirestore.instance
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .add({
          'uId': uId,
          'text': commentText,
          'dateTime': DateTime.now().toIso8601String(),
        })
        .then((value) {
          emit(CommentStorySuccessState());
        });
  }

  // 7. الاشتراك (Subscribe/Follow)
  // هذه العملية عادة تتم على مستوى UserInfoData وليس الـ Story
  // ولكن يمكن تنفيذها من هنا بتحديث قائمة الـ followers للمستخدم صاحب القصة
  void subscribeToUser(String currentUserId, String storyCreatorId) {
    // هنا نقوم بتحديث كولكشن users
    // adding currentUserId to storyCreatorId's followers list
    // and adding storyCreatorId to currentUserId's following list
  }

  // دالة داخلية لتسجيل الاهتمام (لبناء التوصيات)
  void registerUserInterest(String myId, String authorId) {
    FirebaseFirestore.instance.collection(AuthString.fSUsers).doc(myId).update({
      'interestedIn': FieldValue.arrayUnion([authorId]),
    });
  }

  // 1. تسجيل المشاهدة + الخوارزمية الذكية (Monitoring logic)
  void markStoryAsViewed(
    String storyId,
    String storyOwnerId,
    String currentUserId,
  ) {
    // تحديث القصة لإضافة المستخدم الحالي لقائمة المشاهدين
    FirebaseFirestore.instance.collection('stories').doc(storyId).update({
      'views': FieldValue.arrayUnion([currentUserId]),
    });

    // --- الخوارزمية الذكية (Monitoring) ---
    // إذا شاهدت قصة لشخص ما، نضيفه لقائمة "اهتماماتي" (interestedIn)
    // هذا سيجعل قصصه تظهر لي لاحقاً حتى لو لم أكن أتابعه
    if (storyOwnerId != currentUserId) {
      FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(currentUserId)
          .update({
            'interestedIn': FieldValue.arrayUnion([storyOwnerId]),
          });
    }
  }

  // 2. نظام المتابعة (Follow/Unfollow)
  void toggleFollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    // نحصل على وثيقة المستخدم الحالي لنعرف هل يتابعه أم لا
    var userDoc = await FirebaseFirestore.instance
        .collection(AuthString.fSUsers)
        .doc(currentUserId)
        .get();
    List following = userDoc.data()?['following'] ?? [];

    if (following.contains(targetUserId)) {
      // إلغاء المتابعة
      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(currentUserId)
          .update({
            'following': FieldValue.arrayRemove([targetUserId]),
          });
      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(targetUserId)
          .update({
            'followers': FieldValue.arrayRemove([currentUserId]),
          });
    } else {
      // متابعة
      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(currentUserId)
          .update({
            'following': FieldValue.arrayUnion([targetUserId]),
          });
      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(targetUserId)
          .update({
            'followers': FieldValue.arrayUnion([currentUserId]),
          });
    }
    // يمكن عمل emit لحالة نجاح لتحديث الواجهة
    emit(FollowUserSuccessState());
  }

  // 3. جلب القصص الذكي (Smart Feed)
  // هذه الدالة تستبدل getStories القديمة
  void getSmartStories(String currentUserId) async {
    emit(GetStoriesLoadingState());

    try {
      // أ. جلب بيانات المستخدم الحالي لمعرفة من يتابع ومن يهتم بهم
      var userDoc = await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(currentUserId)
          .get();
      List<String> following = List<String>.from(
        userDoc.data()?['following'] ?? [],
      );
      List<String> interestedIn = List<String>.from(
        userDoc.data()?['interestedIn'] ?? [],
      );

      // ب. جلب القصص من آخر 24 ساعة
      var querySnapshot = await FirebaseFirestore.instance
          .collection('stories')
          .orderBy('dateTime', descending: false) // ترتيب زمني
          .get();

      groupedStories = {}; // تصفير القائمة

      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        DateTime storyTime = DateTime.parse(data['dateTime']);

        // التحقق من الوقت (24 ساعة)
        if (DateTime.now().difference(storyTime).inHours < 24) {
          String ownerId = data['uId'];

          // --- الفلترة (الزبدة) ---
          // نعرض القصة إذا:
          // 1. أنا صاحب القصة
          // 2. أتابع الشخص (Following)
          // 3. الشخص ضمن اهتماماتي (Watching history - Monitoring)
          if (ownerId == currentUserId ||
              following.contains(ownerId) ||
              interestedIn.contains(ownerId)) {
            StoryModel model = StoryModel.fromJson(data);

            if (groupedStories.containsKey(ownerId)) {
              groupedStories[ownerId]!.add(model);
            } else {
              groupedStories[ownerId] = [model];
            }
          }
        }
      }
      emit(GetStoriesSuccessState());
    } catch (e) {
      emit(GetStoriesErrorState(e.toString()));
    }
  }
}
