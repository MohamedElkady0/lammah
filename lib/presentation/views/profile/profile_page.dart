import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/model/post_model.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/post/post_cubit.dart';
import 'package:lammah/presentation/views/story/widget/post_item_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // بيانات المستخدم الحالي
    var user = context.read<AuthCubit>().currentUserInfo;

    return BlocBuilder<PostCubit, PostStates>(
      builder: (context, state) {
        var cubit = PostCubit.get(context);

        // فلترة المنشورات لعرض منشورات المستخدم الحالي فقط
        List<PostModel> myPosts = cubit.posts
            .where((element) => element.uId == user?.userId)
            .toList();

        return Scaffold(
          key: widget.scaffoldKey,
          appBar: AppBar(title: Text(user?.name ?? 'Profile'), elevation: 0),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 1. رأس الملف الشخصي (Header)
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // الغلاف (Cover) - يمكن إضافته للموديل لاحقاً
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.blueAccent.withAlpha(300),
                          // child: Image(...) // صورة غلاف
                        ),
                      ),
                      // الصورة الشخصية
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: CachedNetworkImageProvider(
                            user?.image ?? '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  user?.name ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '', // أو الـ bio
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // 2. إحصائيات (متابعين - متابعة - منشورات)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Posts", "${myPosts.length}"),
                    _buildStatItem(
                      "Followers",
                      "${user?.followers?.length ?? 0}",
                    ), // تأكد أن الموديل يحتوي followers
                    _buildStatItem(
                      "Following",
                      "${user?.following?.length ?? 0}",
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),

                // 3. منشوراتي (My Posts)
                if (state is GetPostsLoadingState)
                  const Center(child: CircularProgressIndicator())
                else if (myPosts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text("لم تقم بنشر أي شيء بعد."),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: myPosts.length,
                    itemBuilder: (context, index) {
                      return PostItemWidget(
                        post: myPosts[index],
                        currentUserId: user?.userId ?? '',
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
//           PopApp(
//             offset: const Offset(50, 0),
//             index: 3,
//             title: [ChatString.settings, ChatString.help, ChatString.logout],
//             isMenu: true,
//             onTap: [
//               () {
//                 Navigator.of(
//                   context,
//                 ).push(MaterialPageRoute(builder: (context) => SettingPage()));
//               },
//               () {
//                 Navigator.of(
//                   context,
//                 ).push(MaterialPageRoute(builder: (context) => HelpPage()));
//               },
//               () {
//                 context.read<AuthCubit>().signOut();
//               },
//             ],
//           ),