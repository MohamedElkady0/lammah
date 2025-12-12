import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/model/category.dart';
import 'package:lammah/data/model/transaction.dart';
import 'package:lammah/data/service/database_helper.dart';
import 'package:lammah/domian/transaction/transaction_cubit.dart';
import 'package:uuid/uuid.dart';

class AddTransactionSheet extends StatefulWidget {
  final DateTime selectedDate;
  const AddTransactionSheet({super.key, required this.selectedDate});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();

  bool _isRecurring = false; // هل العملية متكررة؟
  int _selectedDay = 1; // يوم التكرار (من 1 إلى 28 لضمان الشهور القصيرة)

  // الحالة الافتراضية مصروف
  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = defaultCategories[0];
  }

  // دالة مساعدة لتحديث الفئة تلقائياً عند تغيير النوع (اختياري لتحسين التجربة)
  void _updateCategoryBasedOnType(TransactionType type) {
    setState(() {
      _selectedType = type;
      if (type == TransactionType.income) {
        // محاولة العثور على فئة "دخل" أو "راتب" وتحديدها تلقائياً
        try {
          _selectedCategory = defaultCategories.firstWhere(
            (c) => c.name.contains('دخل') || c.id == '8',
          );
        } catch (e) {
          // إذا لم توجد، ابق على الفئة الحالية
        }
      } else {
        // العودة للفئة الأولى عند التحويل لمصروف
        if (_selectedCategory?.name == 'دخل') {
          _selectedCategory = defaultCategories[0];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              'تسجيل عملية جديدة',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // 1. مفتاح التبديل بين الدخل والمصروف (الجديد)
            // ==========================================
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(50),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.withAlpha(80)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeSelector(
                      title: 'مصروف',
                      type: TransactionType.expense,
                      color: Colors.redAccent,
                      isSelected: _selectedType == TransactionType.expense,
                    ),
                  ),
                  Expanded(
                    child: _buildTypeSelector(
                      title: 'دخل',
                      type: TransactionType.income,
                      color: Colors.green,
                      isSelected: _selectedType == TransactionType.income,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. حقل المبلغ
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 15),

            // 3. حقل الوصف
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'الوصف (مثلاً: راتب، إيجار...)',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
              ),
            ),
            const SizedBox(height: 15),

            // 4. قائمة الفئات
            DropdownButtonFormField<Category>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'الفئة',
                prefixIcon: Icon(_selectedCategory?.icon ?? Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(100),
              ),
              items: defaultCategories.map((Category category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(category.icon, size: 18, color: category.color),
                      const SizedBox(width: 10),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Category? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            const SizedBox(height: 25),

            // يظهر الخيار فقط للمصروفات
            if (_selectedType == TransactionType.expense) ...[
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("تكرار هذه العملية شهرياً"),
                subtitle: const Text("سيتم خصمها تلقائياً كل شهر"),
                value: _isRecurring,
                onChanged: (val) {
                  setState(() {
                    _isRecurring = val;
                  });
                },
                activeThumbColor: colorScheme.primary,
              ),

              // إذا تم التفعيل، أظهر قائمة لاختيار اليوم
              if (_isRecurring)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text("كرر يوم: "),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                        value: _selectedDay,
                        items: List.generate(28, (index) => index + 1).map((
                          day,
                        ) {
                          return DropdownMenuItem(
                            value: day,
                            child: Text(day.toString()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDay = val!;
                          });
                        },
                      ),
                      const Text(" من كل شهر"),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 20),

            // ... زر الحفظ

            // 5. زر الحفظ
            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == TransactionType.income
                      ? Colors.green
                      : colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                onPressed: () async {
                  var message = ScaffoldMessenger.of(context);
                  var nav = Navigator.of(context);
                  final amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (amount > 0 && _selectedCategory != null) {
                    // 1. إضافة المعاملة الحالية (لليوم)
                    final newTransaction = Transaction(
                      id: const Uuid().v4(),
                      title: _titleController.text,
                      amount: amount,
                      date: widget.selectedDate,
                      type: _selectedType,
                      category: _selectedCategory!,
                    );
                    context.read<TransactionCubit>().addTransaction(
                      newTransaction,
                    );

                    // 2. إذا كانت متكررة، احفظها في جدول التكرار
                    if (_isRecurring &&
                        _selectedType == TransactionType.expense) {
                      await DatabaseHelper.instance.insertRecurringTransaction({
                        'id': const Uuid().v4(),
                        'title': _titleController.text,
                        'amount': amount,
                        'categoryId': _selectedCategory!.id,
                        'dayOfMonth': _selectedDay,
                        'lastProcessedDate': DateTime.now()
                            .toIso8601String(), // نعتبر أنها تمت اليوم
                      });

                      if (mounted) {
                        message.showSnackBar(
                          SnackBar(
                            content: Text(
                              "تم جدولة الدفع ليوم $_selectedDay من كل شهر",
                            ),
                          ),
                        );
                      }
                    }

                    nav.pop();
                  }
                },
                child: const Text(
                  'حفظ العملية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت زر الاختيار (تصميم خاص)
  Widget _buildTypeSelector({
    required String title,
    required TransactionType type,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _updateCategoryBasedOnType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
