import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/presentation/views/chat/widget/knowing_friend.dart';
import 'package:lammah/presentation/views/chat/widget/search_app.dart';

class NewJourney extends StatelessWidget {
  const NewJourney({super.key});

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double w = ConfigApp.width;
    double h = ConfigApp.height;
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Stack(
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
            top: w * 0.01,
            left: w * 0.05,
            right: w * 0.05,
            child: const SearchApp(),
          ),
        ],
      ),
    );
  }
}
