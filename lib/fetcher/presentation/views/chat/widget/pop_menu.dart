import 'package:flutter/material.dart';

PopupMenuItem<dynamic> popMenu(
  BuildContext context, {
  required bool isMenu,
  String? title,
  String? image,
  String? chat,
  String? date,
  void Function()? onTap,
}) {
  return PopupMenuItem(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
    onTap: onTap,
    child: isMenu
        ? Text(
            title ?? '',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          )
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.onTertiary,
                    backgroundImage: image != null ? AssetImage(image) : null,
                  ),
                  const SizedBox(width: 10.0),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onTertiary.withAlpha(150),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              date ?? '',
                              style: Theme.of(context).textTheme.labelSmall!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiary.withAlpha(150),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
  );
}
