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
      'date': date.toIso8601String().substring(0, 10), // YYYY-MM-DD
    };
  }

  // لتحويل Map من DB إلى Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
    );
  }

  @override
  List<Object?> get props => [id, title, content, date];
}
