import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lammah/data/model/story_model.dart'; // تأكد من المسار
import 'package:lammah/domian/auth/auth_cubit.dart'; // تأكد من المسار
import 'package:lammah/domian/story/story_cubit.dart'; // تأكد من المسار
import 'package:lammah/presentation/views/story/view/add_story_screen.dart'; // تأكد من المسار
import 'package:lammah/presentation/views/story/view/story_view_screen.dart'; // تأكد من المسار

class StoriesListWidget extends StatelessWidget {
  const StoriesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // الحصول على بيانات المستخدم مرة واحدة
    final user = context.read<AuthCubit>().currentUserInfo;

    return BlocProvider(
      create: (context) => StoryCubit()..getStories(),
      child: BlocConsumer<StoryCubit, StoryStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = StoryCubit.get(context);

          // 1. حالة التحميل: إظهار دائرة تحميل بدلاً من القائمة الفارغة
          if (state is GetStoriesLoadingState) {
            return SizedBox(
              height: 100,
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          // 2. حالة الخطأ: إظهار زر لإعادة المحاولة (اختياري)
          if (state is GetStoriesErrorState) {
            return SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  "حدث خطأ في تحميل القصص",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            );
          }

          return Container(
            height: 110,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // +1 لزر الإضافة
              itemCount: cubit.groupedStories.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                // 1. زر إضافة قصة
                if (index == 0) {
                  // نمرر الـ user للدالة لتجنب جلبه مرة أخرى
                  return _buildAddStoryButton(context, cubit, user?.image);
                }

                // 2. قصص المستخدمين
                // (index - 1) لأن العنصر 0 محجوز لزر الإضافة
                String userKey = cubit.groupedStories.keys.elementAt(index - 1);
                List<StoryModel> userStories = cubit.groupedStories[userKey]!;
                StoryModel firstStory = userStories.first;

                return InkWell(
                  onTap: () {
                    // هنا أيضاً نحتاج تمرير الكيوبت إذا كنت تريد عمل لايك أو حذف
                    // أو يمكنك الاكتفاء بعرض القصص فقط (حسب تصميمك)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit, // تمرير نفس الكيوبت للشاشة التالية
                          child: StoryViewScreen(
                            stories: userStories,
                            initialIndex: 0,
                            currentUserId: user?.userId ?? '',
                          ),
                        ),
                      ),
                    ).then((value) {
                      // تحديث القائمة عند العودة (في حال تم حذف قصة مثلاً)
                      cubit.getStories();
                    });
                  },
                  child: _buildUserBubble(firstStory),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // --- الدوال المساعدة ---

  Widget _buildAddStoryButton(
    BuildContext context,
    StoryCubit cubit,
    String? userImage,
  ) {
    var nav = Navigator.of(context);
    return InkWell(
      onTap: () {
        cubit.getStoryImage().then((value) {
          // التحقق من أن الكيوبت لا يزال يحمل الملف
          if (cubit.storyMediaFile != null) {
            // ملاحظة هامة: يجب تمرير الكيوبت إلى الشاشة الجديدة
            nav.push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit, // نمرر النسخة الحالية التي تحتوي على الملف
                  child: AddStoryScreen(),
                ),
              ),
            );
          }
        });
      },
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                // فحص الصورة لتجنب الكراش
                backgroundImage: (userImage != null && userImage.isNotEmpty)
                    ? NetworkImage(userImage)
                    : null,
                child: (userImage == null || userImage.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white,
                child: Icon(Icons.add, size: 15, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text('قصتك', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildUserBubble(StoryModel story) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: CircleAvatar(
            radius: 27,
            backgroundColor: Colors.grey[200],
            backgroundImage:
                (story.userImage != null && story.userImage!.isNotEmpty)
                ? CachedNetworkImageProvider(story.userImage!)
                : null,
            child: (story.userImage == null || story.userImage!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 70,
          child: Text(
            story.name ?? 'User',
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
