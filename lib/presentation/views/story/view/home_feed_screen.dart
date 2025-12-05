import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/post/post_cubit.dart';
import 'package:lammah/domian/story/story_cubit.dart';
import 'package:lammah/presentation/views/story/view/add_post_screen.dart';
import 'package:lammah/presentation/views/story/widget/post_item_widget.dart';
import 'package:lammah/presentation/views/story/widget/stories_list_widget.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات المستخدم الحالي لعمل اللايك
    final user = context.read<AuthCubit>().currentUserInfo;
    final currentUserId = user?.userId ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.primary,
      child: RefreshIndicator(
        onRefresh: () async {
          // استدعاء دوال الجلب مرة أخرى
          StoryCubit.get(context).getStories();
          PostCubit.get(context).getPosts();
          // انتظار قليل لجمالية الحركة (اختياري)
          await Future.delayed(const Duration(seconds: 1));
        },
        color: Colors.blue,
        child: CustomScrollView(
          slivers: [
            // العنوان
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 8),
                    Text(
                      "اكتشف كل جديد",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // نحتاج تمرير PostCubit للشاشة الجديدة أيضاً
                        var cubit = PostCubit.get(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: cubit, // تمرير نفس الكيوبت
                              child: const AddPostScreen(),
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // شريط القصص (Stories)
            const SliverToBoxAdapter(child: StoriesListWidget()),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // قائمة المنشورات (Posts)
            // نستخدم BlocConsumer على مستوى الـ PostCubit فقط
            BlocConsumer<PostCubit, PostStates>(
              listener: (context, state) {},
              builder: (context, state) {
                var cubit = PostCubit.get(context);

                if (state is GetPostsLoadingState && cubit.posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (cubit.posts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "لا توجد منشورات",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return PostItemWidget(
                      post: cubit.posts[index],
                      currentUserId: currentUserId,
                    );
                  }, childCount: cubit.posts.length),
                );
              },
            ),

            // مسافة سفلية
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
