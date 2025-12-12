import 'package:timeago/timeago.dart' as timeago;

String formatTimeAgo(String? dateTimeString) {
  if (dateTimeString == null) return '';
  DateTime date = DateTime.parse(dateTimeString);
  // locale: 'ar' ليعرض الوقت بالعربية
  return timeago.format(date, locale: 'ar');
}
