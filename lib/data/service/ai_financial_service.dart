import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lammah/data/model/transaction.dart';

class AiFinancialService {
  static const String _apiKey = 'AIzaSyAaTucnPhhlZ--1ykB3uquMapjZ_US1oSQ';

  late final GenerativeModel _model;

  AiFinancialService() {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }

  Future<String> getFinancialAdvice(List<Transaction> transactions) async {
    try {
      // 1. تصفية البيانات (نرسل المصاريف فقط لهذا الشهر لتقليل حجم البيانات)
      final now = DateTime.now();
      final thisMonthExpenses = transactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                t.date.month == now.month &&
                t.date.year == now.year,
          )
          .toList();

      if (thisMonthExpenses.isEmpty) {
        return "لا توجد مصاريف كافية هذا الشهر لتحليلها. حاول تسجيل بعض العمليات أولاً.";
      }

      // 2. تجميع البيانات كنص ليفهمه الذكاء الاصطناعي
      // نقوم بتجميع المصاريف حسب الفئة
      Map<String, double> categoryTotals = {};
      double totalSpent = 0;

      for (var t in thisMonthExpenses) {
        categoryTotals.update(
          t.category.name,
          (value) => value + t.amount,
          ifAbsent: () => t.amount,
        );
        totalSpent += t.amount;
      }

      StringBuffer promptBuffer = StringBuffer();
      promptBuffer.writeln(
        "أنت مستشار مالي ذكي ومرح. سأعطيك قائمة بمصاريفي لهذا الشهر.",
      );
      promptBuffer.writeln("إجمالي المصروفات: $totalSpent\$");
      promptBuffer.writeln("التفاصيل حسب الفئة:");

      categoryTotals.forEach((category, amount) {
        promptBuffer.writeln("- $category: $amount\$");
      });

      promptBuffer.writeln("\nالمطلوب منك:");
      promptBuffer.writeln("1. حلل هذه المصاريف باختصار.");
      promptBuffer.writeln(
        "2. أخبرني أين أنفق أكثر من اللازم؟ (بالنسبة المئوية).",
      );
      promptBuffer.writeln(
        "3. أعطني نصيحة عملية واحدة ومحددة جداً للتوفير بناءً على هذه الأرقام.",
      );
      promptBuffer.writeln(
        "تحدث معي بصيغة المخاطب، وباللغة العربية، وكن ودوداً.",
      );

      // 3. إرسال الطلب لـ Gemini
      final content = [Content.text(promptBuffer.toString())];
      final response = await _model.generateContent(content);

      return response.text ?? "لم أتمكن من توليد نصيحة في الوقت الحالي.";
    } catch (e) {
      return "حدث خطأ أثناء الاتصال بالمستشار الذكي: $e";
    }
  }
}
