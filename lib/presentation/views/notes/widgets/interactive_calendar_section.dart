import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl; // لتنسيق التاريخ
import 'package:lammah/data/model/note.dart';
import 'package:lammah/data/model/transaction.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart';
import 'package:lammah/presentation/views/notes/widgets/cart/note_card.dart';
import 'package:lammah/presentation/views/notes/widgets/cart/transaction_card.dart';
import 'package:lammah/presentation/views/notes/widgets/sheet_note.dart'; // تأكد أن هذا الملف يحتوي على showAddActionSheet
import 'package:table_calendar/table_calendar.dart';

class InteractiveCalendarSection extends StatefulWidget {
  const InteractiveCalendarSection({super.key});

  @override
  State<InteractiveCalendarSection> createState() =>
      _InteractiveCalendarSectionState();
}

class _InteractiveCalendarSectionState
    extends State<InteractiveCalendarSection> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _selectedDayEvents = [];

  // 1. متغير للتحكم في ظهور التقويم (افتراضياً مغلق لجعل الواجهة أنظف)
  bool _isCalendarExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _updateSelectedEventsFromState(context.read<TransactionCubit>().state);
  }

  void _updateSelectedEventsFromState(TransactionState state) {
    if (state is TransactionLoaded && _selectedDay != null) {
      final dayKey = DateTime.utc(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );
      setState(() {
        _selectedDayEvents = state.events[dayKey] ?? [];
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _updateSelectedEventsFromState(context.read<TransactionCubit>().state);
      });

      // 2. طلبك: إظهار الشيت مباشرة عند الضغط على اليوم
      showAddActionSheet(context, selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // تنسيق التاريخ للعرض في الشريط العلوي
    String headerDateText = _selectedDay != null
        ? intl.DateFormat('d MMMM yyyy', 'ar').format(_selectedDay!)
        : 'اختر تاريخاً';

    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        _updateSelectedEventsFromState(state);
      },
      builder: (context, state) {
        final eventsMap = (state is TransactionLoaded)
            ? state.events
            : <DateTime, List<dynamic>>{};

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            // إضافة ظل خفيف للحاوية بالكامل
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 3. شريط التحكم (Header) للفتح والإغلاق
              InkWell(
                onTap: () {
                  setState(() {
                    _isCalendarExpanded = !_isCalendarExpanded;
                  });
                },
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "التقويم",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                headerDateText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // أيقونة تتغير حسب الحالة (مفتوح/مغلق)
                      Icon(
                        _isCalendarExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // 4. التقويم القابل للإخفاء (AnimatedCrossFade)
              AnimatedCrossFade(
                firstChild: Container(), // الحالة المخفية (فارغ)
                secondChild: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    eventLoader: (day) {
                      final dayKey = DateTime.utc(day.year, day.month, day.day);
                      return eventsMap[dayKey] ?? [];
                    },
                    locale: 'ar',
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),

                    // تنسيق مبسط للتقويم
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(100),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.orange, // لون النقاط للأحداث
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                crossFadeState: _isCalendarExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              // 5. قائمة الأحداث (تظهر دائماً لليوم المختار)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(50),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "أحداث هذا اليوم:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        // زر صغير للإضافة السريعة إذا كان التقويم مغلقاً
                        if (!_isCalendarExpanded)
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              if (_selectedDay != null) {
                                showAddActionSheet(context, _selectedDay!);
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_selectedDayEvents.isNotEmpty)
                      ..._selectedDayEvents.map((event) {
                        if (event is Note) {
                          return NoteCard(note: event);
                        }
                        if (event is Transaction) {
                          return TransactionCard(transaction: event);
                        }
                        return const SizedBox.shrink();
                      })
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy,
                                color: Colors.grey[300],
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "لا توجد أحداث.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
