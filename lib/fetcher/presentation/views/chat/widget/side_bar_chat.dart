import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/utils/chat_string.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:lammah/fetcher/presentation/views/chat/widget/pop_chats.dart';

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
          PopChats(
            offset: const Offset(50, 0),
            index: 4,
            title: [
              ChatString.account,
              ChatString.settings,
              ChatString.help,
              ChatString.logout,
            ],
            isMenu: true,
            onTap: [
              () {},
              () {},
              () {},
              () {
                context.read<AuthCubit>().signOut();
              },
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.groups,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          PopChats(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            offset: const Offset(50, -97),
            isMenu: false,
            index: 4,
            title: ['Ali', 'Adel', 'Samy', 'Mohamed'],
            images: [
              'assets/images/chat.png',
              'assets/images/house.png',
              'assets/images/slack.png',
              'assets/images/translate.png',
            ],
            chats: ['Hello world', 'Hello world', 'Hello world', 'Hello world'],
            dates: ['today', 'yesterday', '2 days ago', '3 days ago'],
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.web_stories,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.event_note,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
