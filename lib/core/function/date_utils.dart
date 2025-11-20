import 'package:cloud_firestore/cloud_firestore.dart';

String formatLastSeen(Timestamp? lastSeen) {
  if (lastSeen == null) return 'غير معروف';

  final DateTime date = lastSeen.toDate();
  final Duration diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) {
    return 'نشط الآن'; // أو قبل ثوانٍ
  } else if (diff.inMinutes < 60) {
    return 'منذ ${diff.inMinutes} دقيقة';
  } else if (diff.inHours < 24) {
    return 'منذ ${diff.inHours} ساعة';
  } else if (diff.inDays < 7) {
    return 'منذ ${diff.inDays} يوم';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}
