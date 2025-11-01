import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/presentation/views/chat/views/chat/record_widget.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key, required this.message, required this.isFriend});
  final Map<String, dynamic> message;
  final bool isFriend;

  // ويدجت لعرض الرسائل النصية
  Widget _buildTextMessage(BuildContext context) {
    return Text(
      message['message'] ?? '', // التأكد من عدم وجود قيمة null
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  /// ويدجت لعرض الرسائل الصوتية
  Widget _buildAudioMessage(BuildContext context) {
    final String audioUrl = message['audioUrl'] ?? '';
    final int duration = message['duration'] ?? 0;

    if (audioUrl.isEmpty) {
      return const Text(
        'لا يمكن تشغيل الرسالة الصوتية',
        style: TextStyle(color: Colors.white),
      );
    }

    return AudioPlayerWidget(audioUrl: audioUrl, durationInMillis: duration);
  }

  // ويدجت لعرض الصور مع الشرح
  Widget _buildImageMessage(BuildContext context) {
    final List<dynamic> imageUrls = message['imageUrls'] ?? [];
    final String caption = message['caption'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // استخدام GridView لعرض الصور بشكل أنيق
        GridView.builder(
          itemCount: imageUrls.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: imageUrls.length > 1
                ? 2
                : 1, // عمود واحد إذا كانت صورة، عمودان لأكثر
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                // إظهار مؤشر تحميل أثناء جلب الصورة
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                // إظهار أيقونة خطأ في حال فشل التحميل
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            );
          },
        ),
        // عرض الشرح فقط إذا لم يكن فارغاً
        if (caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 5, left: 5),
            child: Text(
              caption,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);

    // التحقق من نوع الرسالة
    final bool isImageMessage =
        message.containsKey('type') && message['type'] == 'image';

    final bool isAudioMessage =
        message.containsKey('type') && message['type'] == 'audio';

    return Align(
      alignment: isFriend
          ? Alignment.topLeft
          : Alignment.topRight, // يمكنك تعديل هذا بناءً على المُرسِل
      child: InkWell(
        onLongPress: () {
          // ... (الكود الخاص بك للحذف)
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: ConfigApp.width * 0.7,
                ), // تحديد عرض أقصى للرسالة
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomRight: isFriend ? Radius.circular(12) : Radius.zero,
                    bottomLeft: isFriend ? Radius.zero : Radius.circular(12),
                  ),
                ),
                // عرض الويدجت المناسبة بناءً على نوع الرسالة
                child: isAudioMessage
                    ? _buildAudioMessage(context)
                    : (isImageMessage
                          ? _buildImageMessage(context)
                          : _buildTextMessage(context)),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.jm().format(message['date'].toDate()),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
