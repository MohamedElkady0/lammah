import 'package:flutter/material.dart';

Future<dynamic> menuChat(
  BuildContext context, {
  required int index,
  List<String>? title,
  List<void Function()>? onPressed,
}) {
  return showMenu(
    useRootNavigator: true,
    color: Theme.of(context).colorScheme.tertiary,
    context: context,
    items: [
      for (int i = 0; i < index; i++)
        popMenu(
          context,
          title: title?[i] ?? 'العنصر $i',
          onPressed:
              onPressed?[i] ??
              () {
                // Navigate to item $i
              },
        ),
    ],
    position: RelativeRect.fromLTRB(0, 0, 0, 0),
  );
}

PopupMenuItem<dynamic> popMenu(
  BuildContext context, {
  String? title,
  void Function()? onPressed,
}) {
  return PopupMenuItem(
    onTap: onPressed,
    child: Text(
      title!,
      style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
    ),
  );
}
