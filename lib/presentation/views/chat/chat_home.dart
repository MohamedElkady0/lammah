import 'package:flutter/material.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/data/model/side_bar_model.dart';
import 'package:lammah/presentation/views/chat/views/chat_screen.dart';
import 'package:lammah/presentation/views/chat/views/new_journey.dart';
import 'package:lammah/presentation/views/notes/view/note_page.dart';
import 'package:lammah/presentation/views/story/view/home_feed_screen.dart';
import 'package:lammah/presentation/widgets/side_bar.dart';

class ChatW extends StatefulWidget {
  const ChatW({super.key});

  @override
  State<ChatW> createState() => _ChatWState();
}

class _ChatWState extends State<ChatW> {
  int _selectedIndex = 0;

  // قائمة الصفحات (يجب أن تظل كما هي)
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

    // استخدم Scaffold لتجنب مشاكل الخلفية السوداء الافتراضية
    return Stack(
      children: [
        // 1. المحتوى الرئيسي (هنا نضع IndexedStack)
        // نضعه أولاً ليكون في الطبقة الخلفية
        Positioned(
          top: 0,
          left: w * 0.05 + 40, // نفس المسافة التي حددتها أنت للسايد بار
          right: 0,
          bottom: 0,

          // === هنا الحل ===
          // IndexedStack يأخذ كل الصفحات مرة واحدة ويخفي/يظهر المطلوب
          child: IndexedStack(
            index: _selectedIndex, // يحدد الصفحة المعروضة حالياً
            children: _pages, // نعطيه القائمة الكاملة للصفحات
          ),
        ),

        // 2. الشريط الجانبي (Sidebar)
        // نضعه ثانياً ليكون في الطبقة العلوية (فوق المحتوى)
        Positioned(
          left: w * 0.001,
          top: w * 0.01,
          child: Sidebar(
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            color: Theme.of(context).colorScheme.onPrimary,
            activeColor: Theme.of(context).colorScheme.primary,
            tabBackgroundColor: Theme.of(context).colorScheme.onPrimary,
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
      ],
    );
  }
}
