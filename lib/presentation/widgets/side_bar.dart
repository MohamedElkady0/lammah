import 'package:flutter/material.dart';
import 'package:lammah/data/model/side_bar_model.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;
  final List<SidebarItem> items;

  // خصائص التصميم (اختيارية ولها قيم افتراضية)
  final Color activeColor;
  final Color color;
  final Color tabBackgroundColor;
  final double gap;
  final EdgeInsets padding;
  final Duration animationDuration;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    required this.items,
    this.activeColor = Colors.white, // لون النص والأيقونة عند التحديد
    this.color = Colors.grey, // لون الأيقونة غير المحددة
    this.tabBackgroundColor = Colors.blueAccent, // خلفية الزر المحدد
    this.gap = 10.0, // المسافة بين الأيقونة والنص
    this.padding = const EdgeInsets.all(16),
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // عرض الشريط الجانبي يعتمد على المحتوى، لكن يمكنك تحديده بـ width ثابت إن أردت
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      color: Theme.of(
        context,
      ).colorScheme.primary.withAlpha(100), // خلفية الشريط الجانبي نفسه
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // يأخذ أقل مساحة عمودية ممكنة (أو Max لملء الطول)
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          SidebarItem item = entry.value;
          bool isSelected = selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ), // مسافة بين كل زر والآخر
            child: GestureDetector(
              onTap: () => onTabChange(index),
              child: AnimatedContainer(
                duration: animationDuration,
                padding: padding,
                decoration: BoxDecoration(
                  color: isSelected ? tabBackgroundColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    30,
                  ), // حواف دائرية (Pill Shape)
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min, // العرض يتقلص ليتناسب مع المحتوى
                  children: [
                    Icon(item.icon, color: isSelected ? activeColor : color),
                    // نستخدم AnimatedSize أو شرط بسيط لإظهار النص
                    if (isSelected)
                      Row(
                        children: [
                          SizedBox(width: gap),
                          Text(
                            item.text,
                            style: TextStyle(
                              color: activeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
