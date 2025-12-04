import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/model/story_model.dart';
import 'package:lammah/domian/story/story_cubit.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

import '../widget/comments_bottom .dart';

class StoryViewScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  final String currentUserId;

  const StoryViewScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
    required this.currentUserId,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  final StoryController controller = StoryController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // تحضير العناصر
    List<StoryItem> storyItems = widget.stories.map((story) {
      if (story.mediaType == 'video') {
        return StoryItem.pageVideo(
          story.mediaUrl!,
          controller: controller,
          duration: const Duration(seconds: 15), // مدة افتراضية أو من الفيديو
        );
      } else {
        return StoryItem.pageImage(
          url: story.mediaUrl!,
          controller: controller,
          duration: const Duration(seconds: 5),
        );
      }
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: BlocConsumer<StoryCubit, StoryStates>(
        listener: (context, state) {
          // 1. حالة حذف القصة
          if (state is DeleteStorySuccessState) {
            Navigator.pop(context); // إغلاق شاشة العرض
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم حذف القصة')));
          }

          // 2. حالة المتابعة (اختياري: إظهار Toast سريع)
          if (state is FollowUserSuccessState) {
            // يمكنك استخدام FlutterToast أو SnackBar صغير
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("تم تحديث المتابعة"),
                duration: Duration(milliseconds: 500),
              ),
            );
          }
        },
        builder: (context, state) {
          var cubit = StoryCubit.get(context);
          var currentStory = widget.stories[currentIndex];
          bool isMe = currentStory.uId == widget.currentUserId;

          return Stack(
            children: [
              // 1. عارض القصص
              StoryView(
                storyItems: storyItems,
                controller: controller,

                onStoryShow: (storyItem, index) {
                  // الحل السحري: نؤجل التنفيذ حتى تنتهي الشاشة من الرسم
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // نتأكد أن الصفحة لا تزال موجودة
                    if (mounted) {
                      setState(() {
                        currentIndex = index;
                      });

                      // منطق تسجيل المشاهدات (نضعه هنا أيضاً)
                      var currentStory = widget.stories[index];
                      List views = currentStory.views ?? [];
                      if (!views.contains(widget.currentUserId)) {
                        StoryCubit.get(context).markStoryAsViewed(
                          currentStory.storyId!,
                          currentStory.uId!,
                          widget.currentUserId,
                        );
                      }
                    }
                  });
                },
                onComplete: () => Navigator.pop(context),
              ),

              // 2. الهيدر (صورة المستخدم + زر المتابعة)
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        currentStory.userImage ?? '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentStory.name ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // عرض وقت النشر (مثال: منذ 2 ساعة)
                        // Text("Time Ago", style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 10),

                    // زر المتابعة (يظهر فقط إذا لم تكن قصتي)
                    if (!isMe)
                      InkWell(
                        onTap: () {
                          cubit.toggleFollowUser(
                            currentUserId: widget.currentUserId,
                            targetUserId: currentStory.uId!,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white24,
                          ),
                          child: const Text(
                            "متابعة",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),

                    const Spacer(),

                    // زر الحذف (لصاحب القصة)
                    if (isMe)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => cubit.deleteStory(
                          currentStory.storyId!,
                          currentStory.mediaUrl!,
                        ),
                      ),
                  ],
                ),
              ),

              // 3. الفوتر (المشاهدات، اللايكات، التعليقات)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عرض عدد المشاهدات
                    if (isMe) // عادة المشاهدات تظهر لصاحب القصة فقط
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${currentStory.views?.length ?? 0} مشاهدة",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // حقل فتح التعليقات
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              controller.pause(); // إيقاف القصة
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => CommentsBottomSheet(
                                  storyId: currentStory.storyId!,
                                  currentUserId: widget.currentUserId,
                                ),
                              ).then(
                                (_) => controller.play(),
                              ); // استئناف عند الإغلاق
                            },
                            child: Container(
                              height: 45,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white70),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                "أكتب تعليقاً...",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // زر اللايك مع العداد
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                (currentStory.likes?.contains(
                                          widget.currentUserId,
                                        ) ??
                                        false)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    (currentStory.likes?.contains(
                                          widget.currentUserId,
                                        ) ??
                                        false)
                                    ? Colors.red
                                    : Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                cubit.likeStory(
                                  currentStory.storyId!,
                                  widget.currentUserId,
                                );
                              },
                            ),
                            if ((currentStory.likes?.length ?? 0) > 0)
                              Text(
                                "${currentStory.likes?.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
