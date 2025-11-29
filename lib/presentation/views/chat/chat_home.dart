import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/data/model/side_bar_model.dart';
import 'package:lammah/presentation/views/chat/views/chat_screen.dart';
import 'package:lammah/presentation/views/chat/views/new_journey.dart';
import 'package:lammah/presentation/views/notes/view/note_page.dart';
import 'package:lammah/presentation/views/story/view/home_feed_screen.dart';
import 'package:lammah/presentation/widgets/side_bar_chat.dart';

class ChatW extends StatefulWidget {
  const ChatW({super.key});

  @override
  State<ChatW> createState() => _ChatWState();
}

class _ChatWState extends State<ChatW> {
  int _selectedIndex = 0;

  // قائمة الصفحات
  final List<Widget> _pages = [
    const HomeFeedScreen(),

    const NewJourney(),
    const ChatView(),
    const NotePage(),
  ];

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    double w = ConfigApp.width;

    return Stack(
      children: [
        // الشريط الجانبي
        Positioned(
          left: w * 0.05,
          top: w * 0.1,
          child: Sidebar(
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black87,
            gap: 12,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            items: [
              SidebarItem(icon: Icons.web_stories, text: ''),
              SidebarItem(icon: Icons.flight, text: ''),
              SidebarItem(icon: Icons.chat, text: ''),
              SidebarItem(icon: Icons.event_note, text: ''),
            ],
          ),
        ),

        // المحتوى الرئيسي (الصفحات المتغيرة)
        // تم استخدام Positioned بدلاً من Expanded لأننا داخل Stack
        Positioned(
          top: w * 0.1 + 80, // مسافة أسفل البحث
          left: w * 0.05 + 80, // مسافة يمين السايد بار
          right: w * 0.05,
          bottom: w * 0.1 + 60, // مسافة فوق الزر السفلي
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(90), // شفافية بسيطة لرؤية الخلفية
              borderRadius: BorderRadius.circular(20),
            ),
            child: _pages[_selectedIndex],
          ),
        ),
      ],
    );
  }
}
