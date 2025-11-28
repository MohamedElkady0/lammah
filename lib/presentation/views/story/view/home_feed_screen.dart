import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/post/post_cubit.dart';
import 'package:lammah/presentation/views/story/widget/post_item_widget.dart';
import 'package:lammah/presentation/views/story/widget/stories_list_widget.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات المستخدم الحالي لعمل اللايك
    final user = context.read<AuthCubit>().currentUserInfo;
    final currentUserId = user?.userId ?? '';

    // نستخدم MultiBlocProvider لتوفير كلا الكيوبت
    return Scaffold(
      backgroundColor: Colors.grey[100], // لون خلفية خفيف لتمييز الكروت
      body: CustomScrollView(
        slivers: [
          // العنوان
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "اكتشف",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                return const SliverFillRemaining(
                  child: Center(child: Text("لا توجد منشورات")),
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
    );
  }
}
