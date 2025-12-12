class PrivateTask {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime deadline; // <--- الحقل الجديد

  PrivateTask({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.deadline,
  });

  // تحويل من SQLite
  factory PrivateTask.fromMap(Map<String, dynamic> map) {
    return PrivateTask(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      // SQLite يحفظ التاريخ كـ String بصيغة ISO8601
      deadline: DateTime.parse(map['deadline']),
    );
  }

  // تحويل إلى SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'deadline': deadline.toIso8601String(),
    };
  }
}
