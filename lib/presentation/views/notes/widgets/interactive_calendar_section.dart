import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lammah/data/model/note.dart';
import 'package:lammah/data/model/transaction.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart';
import 'package:lammah/presentation/views/notes/widgets/cart/note_card.dart';
import 'package:lammah/presentation/views/notes/widgets/cart/transaction_card.dart';
import 'package:lammah/presentation/views/notes/widgets/sheet_note.dart';
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
  // هذا المتغير المحلي سيحتوي على أحداث اليوم المختار فقط
  List<dynamic> _selectedDayEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // عند بدء التشغيل، حاول تحميل أحداث اليوم الحالي من الحالة
    _updateSelectedEventsFromState(context.read<TransactionCubit>().state);
  }

  // دالة لتحديث قائمة الأحداث المعروضة بناءً على الحالة واليوم المختار
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
        // عند تغيير اليوم، أعد تحميل الأحداث من الحالة الحالية للـ Cubit
        _updateSelectedEventsFromState(context.read<TransactionCubit>().state);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<TransactionCubit, TransactionState>(
      builder: (BuildContext context, TransactionState state) {
        final eventsMap = (state is TransactionLoaded)
            ? state.events
            : <DateTime, List<dynamic>>{};

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(500),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TableCalendar(
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: (day) {
                  final dayKey = DateTime.utc(day.year, day.month, day.day);
                  return eventsMap[dayKey] ?? []; // هذا سيعرض النقاط
                },

                locale: 'ar', // تأكد من ضبط اللغة للعربية
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),

                // **** هنا يتم تنفيذ الشرط المطلوب عند الضغط على اليوم ****

                // تنسيق رأس التقويم
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: colorScheme.primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: colorScheme.primary,
                  ),
                ),

                // تنسيق أيام التقويم
                calendarStyle: CalendarStyle(
                  // تنسيق اليوم الحالي
                  todayDecoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(300),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: GoogleFonts.cairo(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),

                  // تنسيق اليوم المختار
                  selectedDecoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(500),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  selectedTextStyle: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),

                  // التنسيق العام
                  defaultTextStyle: GoogleFonts.cairo(
                    color: colorScheme.onSurface,
                  ),
                  weekendTextStyle: GoogleFonts.cairo(color: Colors.redAccent),
                  outsideDaysVisible: false,
                ),

                // تنسيق أيام الأسبوع (سبت، أحد...)
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.cairo(
                    color: colorScheme.onSurface.withAlpha(600),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            ElevatedButton.icon(
              onPressed: () {
                if (_selectedDay != null) {
                  showAddActionSheet(context, _selectedDay!);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("أضف حدثًا لهذا اليوم"),
            ),
            const SizedBox(height: 16.0),

            if (_selectedDayEvents.isNotEmpty)
              ..._selectedDayEvents.map((event) {
                if (event is Note) {
                  print("Building NoteCard for: ${event.title}");
                  return NoteCard(note: event);
                }
                if (event is Transaction) {
                  print("Building TransactionCard for: ${event.title}");
                  return TransactionCard(transaction: event);
                }
                return const SizedBox.shrink();
              })
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "لا توجد أحداث لهذا اليوم.",
                  style: GoogleFonts.cairo(color: Colors.grey),
                ),
              ),
          ],
        );
      },
      listener: (BuildContext context, TransactionState state) {
        _updateSelectedEventsFromState(state);
      },
    );
  }
}
