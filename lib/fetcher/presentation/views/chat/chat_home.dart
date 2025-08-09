import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/utils/chat_string.dart';
import 'package:lammah/fetcher/data/model/user_info.dart';
import 'package:lammah/fetcher/presentation/views/chat/widget/knowing_friend.dart';
import 'package:lammah/fetcher/presentation/views/chat/widget/search_app.dart';
import 'package:lammah/fetcher/presentation/views/chat/widget/side_bar_chat.dart';

class ChatW extends StatefulWidget {
  const ChatW({super.key, required this.userInfoData});
  final UserInfoData userInfoData;

  @override
  State<ChatW> createState() => _ChatWState();
}

class _ChatWState extends State<ChatW> {
  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double w = ConfigApp.width;
    double h = ConfigApp.height;
    return Stack(
      children: [
        MapScreen(userInfoData: widget.userInfoData),
        Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withAlpha(30),
          ),
        ),
        Positioned(
          top: w * 0.1,
          left: w * 0.05 + 60,
          right: w * 0.05,
          child: SearchApp(),
        ),

        Positioned(
          bottom: w * 0.1,
          left: w * 0.05,
          right: w * 0.05,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.airplanemode_on),
            label: const Text(ChatString.startChat),
          ),
        ),
        Positioned(left: w * 0.05, top: w * 0.1, child: SideBarChat()),
      ],
    );
  }
}
