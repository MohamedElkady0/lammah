import 'package:flutter/material.dart';
import 'package:lammah/fetcher/presentation/views/chat/widget/pop_menu.dart';

class PopChats extends StatelessWidget {
  const PopChats({
    super.key,
    required this.index,
    required this.title,
    this.images,
    this.chats,
    this.dates,
    this.onTap,
    required this.isMenu,
    this.icon,
    this.color,
    this.offset,
    this.onSelected,
  });

  final int index;
  final List<String> title;
  final List<String>? images;
  final List<String>? chats;
  final List<String>? dates;
  final bool isMenu;
  final List<void Function()>? onTap;
  final Widget? icon;
  final Color? color;
  final Offset? offset;
  final List<void Function(dynamic)>? onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<dynamic>(
      itemBuilder: (context) {
        return [
          for (int i = 0; i < index; i++)
            isMenu
                ? popMenu(
                    context,
                    isMenu: true,
                    title: title[i],
                    onTap: onTap?[i] ?? () {},
                  )
                : popMenu(
                    context,
                    isMenu: false,
                    title: title[i],
                    image: images?[i] ?? '',
                    chat: chats?[i] ?? '',
                    date: dates?[i] ?? '',
                    onTap: onTap?[i] ?? () {},
                  ),
        ];
      },
      onSelected: onSelected != null
          ? (value) {
              for (var callback in onSelected!) {
                callback(value);
              }
            }
          : null,
      color: color ?? Theme.of(context).colorScheme.onTertiaryContainer,
      offset: offset ?? Offset(0, 0),
      icon:
          icon ??
          Icon(
            Icons.more_vert,
            color: color ?? Theme.of(context).colorScheme.onTertiaryContainer,
          ),
    );
  }
}
