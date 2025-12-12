import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/data/model/category.dart';
import 'package:lammah/data/service/database_helper.dart'; // تأكد من المسار
import 'package:lammah/domian/transaction/transaction_cubit.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // تخزين الميزانيات الحالية
  Map<String, double> _budgets = {};

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgets = await DatabaseHelper.instance.getAllBudgets();
    setState(() {
      _budgets = budgets;
    });
  }

  // دالة لحفظ الميزانية
  Future<void> _updateBudget(String categoryId, double limit) async {
    await DatabaseHelper.instance.setCategoryBudget(categoryId, limit);
    _loadBudgets(); // تحديث الواجهة
    // تحديث الكيوبت لإعادة حساب التنبيهات إذا أردت
    if (mounted) context.read<TransactionCubit>().loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تحديد الميزانية الشهرية")),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          // نحتاج لمعرفة مصاريف هذا الشهر لعرض شريط التقدم
          Map<Category, double> currentExpenses = {};
          if (state is TransactionLoaded) {
            currentExpenses = state.monthlyExpensesByCategory;
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: defaultCategories.length,
            itemBuilder: (context, index) {
              final category = defaultCategories[index];
              // تخطي فئة "الدخل" لأنها لا تحتاج ميزانية
              if (category.name == 'دخل') return const SizedBox.shrink();

              final limit = _budgets[category.id] ?? 0.0;
              final spent = currentExpenses[category] ?? 0.0;
              final progress = limit > 0 ? (spent / limit) : 0.0;

              // تحديد لون الشريط (أخضر آمن، برتقالي تحذير، أحمر خطر)
              Color progressColor = Colors.green;
              if (progress > 0.8) progressColor = Colors.orange;
              if (progress >= 1.0) progressColor = Colors.red;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: category.color.withAlpha(100),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(category.icon, color: category.color),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showEditBudgetDialog(context, category, limit),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("المصروف: $spent\$"),
                          Text("الحد: ${limit > 0 ? limit : 'غير محدد'}\$"),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: progress > 1 ? 1 : progress,
                        backgroundColor: Colors.grey[200],
                        color: progressColor,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      if (progress >= 1.0)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            "تجاوزت الميزانية!",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditBudgetDialog(
    BuildContext context,
    Category category,
    double currentLimit,
  ) {
    final controller = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toString() : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("ميزانية: ${category.name}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "أدخل الحد الأقصى (\$)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0.0;
              _updateBudget(category.id, val);
              Navigator.pop(ctx);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }
}
