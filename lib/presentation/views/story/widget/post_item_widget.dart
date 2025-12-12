import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/function/date_helper.dart';
import 'package:lammah/data/model/post_model.dart';
import 'package:lammah/domian/post/post_cubit.dart';
import 'package:lammah/presentation/views/story/widget/post_comments.dart';
import 'package:lammah/presentation/views/story/widget/video_player_widget.dart';

class PostItemWidget extends StatelessWidget {
  final PostModel post;
  final String currentUserId; // لنعرف هل المستخدم الحالي معجب بالمنشور أم لا

  const PostItemWidget({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // نستخدم BlocBuilder هنا لنجعل هذا المنشور فقط يعيد بناء نفسه عند حدوث لايك
    // هذا يحسن الأداء بدلاً من إعادة بناء الصفحة كاملة
    return BlocBuilder<PostCubit, PostStates>(
      builder: (context, state) {
        var cubit = PostCubit.get(context);
        bool isLiked = post.likes!.contains(currentUserId);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          elevation: 2,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. الرأس (Header)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(
                        post.userImage ?? '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.name ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        // في PostItemWidget أو StoryViewScreen
                        Text(
                          formatTimeAgo(post.dateTime), // أو story.dateTime
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (post.uId ==
                        currentUserId) // تحقق أن المستخدم هو صاحب المنشور
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            // استدعاء دالة الحذف
                            PostCubit.get(context).deletePost(post.postId!);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text('حذف المنشور'),
                                ],
                              ),
                            ),
                          ];
                        },
                        child: const Icon(Icons.more_horiz),
                      ),
                  ],
                ),
              ),

              // 2. النص
              if (post.text != null && post.text!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(post.text!, style: const TextStyle(fontSize: 14)),
                ),
              if (post.postImage != null && post.postImage!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: post.postImage!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else if (post.postVideo != null && post.postVideo!.isNotEmpty)
                // استدعاء ويدجت الفيديو الجديد
                VideoPostWidget(videoUrl: post.postVideo!),

              // 4. الإحصائيات (Likes/Comments Count)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, size: 16, color: Colors.red),
                    const SizedBox(width: 5),
                    Text(
                      '${post.likes?.length ?? 0}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${post.commentsCount ?? 0} تعليق',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 5. أزرار التفاعل (Action Buttons)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // استدعاء الكيوبت لعمل لايك
                        cubit.likePost(post.postId!, currentUserId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.onPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isLiked ? 'أعجبني' : 'إعجاب',
                              style: TextStyle(
                                color: isLiked
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => PostCommentsSheet(
                            postId: post.postId!,
                            currentUserId: currentUserId,
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'تعليق',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
