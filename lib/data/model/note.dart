import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String? content;
  final DateTime date;

  const Note({
    required this.id,
    required this.title,
    this.content,
    required this.date,
  });

  // لتحويل Note إلى Map للتخزين في DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      // تأكد من التخزين بصيغة ISO 8601 كاملة لضمان الدقة
      'date': date.toIso8601String(),
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
    );
  }

  @override
  List<Object?> get props => [id, title, content, date];
}
