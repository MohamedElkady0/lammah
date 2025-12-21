import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/post_model.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/post/post_cubit.dart';
import 'package:lammah/presentation/views/setting/setting_page.dart';
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          key: widget.scaffoldKey,
          appBar: AppBar(
            title: Text(
              'Profile',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                },
              ),
            ],
            leading: Image.asset(AuthString.logo, height: 40, width: 40),
          ),
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Text(
                  user?.email ?? '', // أو الـ bio
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
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
                  Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                      "لم تقم بنشر أي شيء بعد.",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ],
    );
  }
}
