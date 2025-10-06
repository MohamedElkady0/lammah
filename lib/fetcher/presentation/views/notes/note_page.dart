import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lammah/fetcher/data/model/note.dart';
import 'package:lammah/fetcher/data/model/transaction.dart';
import 'package:lammah/fetcher/domian/transaction/transaction_cubit.dart';
import 'package:lammah/fetcher/presentation/views/notes/widgets/add_reminder_sheet.dart';
import 'package:lammah/fetcher/presentation/views/notes/widgets/add_transaction_sheet.dart';
import 'package:lammah/fetcher/presentation/views/notes/widgets/balance_and_analytics_section.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart' as intl;

// ==============================
// الصفحة الرئيسية للملاحظات (NotePage)
// ==============================
class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام ثيم داكن أنيق (يمكنك تغييره حسب ثيم تطبيقك)
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // خلفية الصفحة الأساسية
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'يومياتي المالية',
          style: GoogleFonts.cairo(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      // زر عائم عام (اختياري إذا كنت ستعتمد على ضغط التقويم فقط)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        onPressed: () {
          // فتح إضافة سريعة لليوم الحالي
          showAddActionSheet(context, DateTime.now());
        },
        label: Text(
          "إضافة سريعة",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: const [
            // دمجنا الواجهتين في واحدة لتكون أكثر تفاعلية
            BalanceAndAnalyticsSection(),
            SizedBox(height: 20),
            InteractiveCalendarSection(),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ==============================
// 1. قسم ملخص الرصيد (BalanceSummaryHeader)
// تصميم حديث وأنيق بدلاً من CashMoneyWidget القديم
// ==============================
class BalanceSummaryHeader extends StatelessWidget {
  const BalanceSummaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // محاكاة للبيانات
    final totalAmount = '10,000\$';

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        // تدرج لوني جذاب للخلفية
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.tertiary, // أو لون أفتح قليلاً من الـ primary
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الرصيد الحالي',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            totalAmount,
            style: GoogleFonts.ptSansNarrow(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // شريط التحليلات المصغر (بديل DivCash)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                return MiniChartItem(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// عنصر واحد في شريط التحليلات المصغر
class MiniChartItem extends StatelessWidget {
  final int index;
  const MiniChartItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // محاكاة ارتفاعات مختلفة للأعمدة
    double barHeight = (index % 3 == 0) ? 40.0 : (index % 2 == 0 ? 60.0 : 30.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // العمود البياني
          Container(
            height: barHeight,
            width: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 8),
          // أيقونة أو نص صغير
          Icon(Icons.circle, size: 8, color: Colors.white.withOpacity(0.5)),
        ],
      ),
    );
  }
}

// ==============================
// 2. قسم التقويم التفاعلي (InteractiveCalendarSection)
// يستخدم table_calendar ويحقق الشرط المطلوب عند الضغط
// ==============================
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
                    color: Colors.black.withOpacity(0.05),
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
                    color: colorScheme.primary.withOpacity(0.3),
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
                        color: colorScheme.primary.withOpacity(0.5),
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
                    color: colorScheme.onSurface.withOpacity(0.6),
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
                if (event is Note) return NoteCard(note: event);
                if (event is Transaction)
                  return TransactionCard(transaction: event);
                return const SizedBox.shrink();
              }).toList()
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

// أنشئ هذه الكروت في ملفات منفصلة
class NoteCard extends StatelessWidget {
  final Note note;
  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.note_alt_rounded, color: Colors.orange),
        title: Text(
          note.title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        subtitle: note.content != null ? Text(note.content!) : null,
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    bool isIncome = transaction.type == TransactionType.income;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          transaction.category.icon,
          color: isIncome ? Colors.green : Colors.red,
        ),
        title: Text(
          transaction.title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} ${transaction.amount}\$',
          style: GoogleFonts.cairo(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==============================
// وظيفة إظهار قائمة الخيارات (BottomSheet)
// تظهر عند الضغط على اليوم
// ==============================
void showAddActionSheet(BuildContext context, DateTime date) {
  final colorScheme = Theme.of(context).colorScheme;
  // تنسيق التاريخ المختار للعرض
  String formattedDate = intl.DateFormat(
    'EEEE, d MMMM yyyy',
    'ar',
  ).format(date);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القائمة مع التاريخ
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'إضافة ليوم:',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
            ),
            Text(
              formattedDate,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // الخيارات الثلاثة المطلوبة بتصميم جذاب
            // في الملف الذي يحتوي على showAddActionSheet
            // ...
            // استبدل استدعاءات onTap القديمة بالجديدة
            _buildActionOption(
              context,
              icon: Icons.monetization_on_rounded,
              color: Colors.green,
              title: "معاملة مالية",
              subtitle: "أضف دخلاً أو مصروفاً لهذا اليوم",
              onTap: () {
                Navigator.pop(context); // أغلق الـ action sheet أولاً
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddTransactionSheet(selectedDate: date),
                );
              },
            ),
            _buildActionOption(
              context,
              icon: Icons.notifications_active_rounded,
              color: Colors.blueAccent,
              title: "تذكير",
              subtitle: "اضبط تنبيهاً في هذا التاريخ",
              onTap: () {
                Navigator.pop(context);
                // فتح نافذة إضافة تذكير
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddReminderSheet(selectedDate: date),
                );
              },
            ),

            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ), // للحواف السفلية للهواتف الحديثة
          ],
        ),
      );
    },
  );
}

// عنصر واحد في قائمة الخيارات
Widget _buildActionOption(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      tileColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[400],
      ),
    ),
  );
}

// ==============================
// إعداد التطبيق للتجربة (Main Mock)
// ==============================
