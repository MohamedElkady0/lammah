import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/core/utils/chat_string.dart';
import 'package:lammah/presentation/views/chat/widget/knowing_friend.dart';
import 'package:lammah/presentation/views/chat/widget/search_app.dart';

class NewJourney extends StatelessWidget {
  const NewJourney({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double w = ConfigApp.width;
    double h = ConfigApp.height;
    return Stack(
      children: [
        // الخلفية
        const MapScreen(),

        // طبقة شفافة
        Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withAlpha(30),
          ),
        ),

        // شريط البحث
        Positioned(
          top: w * 0.1,
          left: w * 0.05 + 60,
          right: w * 0.05,
          child: const SearchApp(),
        ),

        // زر بدء المحادثة
        Positioned(
          bottom: w * 0.1,
          left: w * 0.05,
          right: w * 0.05,
          child: ElevatedButton.icon(
            style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.primary.withAlpha(100),
              ),
            ),
            onPressed: () {},
            icon: const Icon(Icons.airplanemode_on),
            label: const Text(ChatString.startChat),
          ),
        ),
      ],
    );
  }
}
