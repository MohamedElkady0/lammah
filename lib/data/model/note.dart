import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String? content;
  final DateTime date;
  final bool isCompleted;

  const Note({
    required this.id,
    required this.title,
    this.content,
    required this.date,
    required this.isCompleted,
  });

  // لتحويل Note إلى Map للتخزين في DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      // تأكد من التخزين بصيغة ISO 8601 كاملة لضمان الدقة
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0, // تخزين كـ int (1 أو 0)
    };
  }

  // =========== هنا يكمن الإصلاح على الأغلب ===========
  // لتحويل Map من DB إلى كائن Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String?,
      // استخدم DateTime.parse لتحويل النص إلى تاريخ
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, content, date];
}
