import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/utils/chat_string.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/updateuser/updateuser_cubit.dart';
import 'package:lammah/presentation/views/chat/views/chat_screen.dart';
import 'package:lammah/presentation/widgets/pop_app.dart';
import 'package:lammah/presentation/views/help/help_page.dart';
import 'package:lammah/presentation/views/notes/view/note_page.dart';
import 'package:lammah/presentation/views/notification/notification_page.dart';
import 'package:lammah/presentation/views/setting/setting_page.dart';
import 'package:lammah/presentation/views/story/story_page.dart';

class SideBarChat extends StatelessWidget {
  const SideBarChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PopApp(
            offset: const Offset(50, 0),
            index: 3,
            title: [ChatString.settings, ChatString.help, ChatString.logout],
            isMenu: true,
            onTap: [
              () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => SettingPage()));
              },
              () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => HelpPage()));
              },
              () {
                context.read<AuthCubit>().signOut();
              },
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            icon: Icon(
              Icons.notifications,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => ChatView()));
            },
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          // PopApp(
          //   icon: Icon(
          //     Icons.chat_bubble_outline,
          //     color: Theme.of(context).colorScheme.onPrimary,
          //   ),
          //   offset: const Offset(50, -97),
          //   isMenu: false,
          //   index: 4,
          //   title: ['Ali', 'Adel', 'Samy', 'Mohamed'],
          //   images: [
          //     'assets/images/chat.png',
          //     'assets/images/house.png',
          //     'assets/images/slack.png',
          //     'assets/images/translate.png',
          //   ],
          //   chats: ['Hello world', 'Hello world', 'Hello world', 'Hello world'],
          //   dates: ['today', 'yesterday', '2 days ago', '3 days ago'],
          // ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => StoryPage()));
            },
            icon: Icon(
              Icons.web_stories,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => NotePage()));
            },
            icon: Icon(
              Icons.event_note,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<UpdateUserCubit>().updateLocation();
            },
            icon: Icon(
              Icons.gps_fixed,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
