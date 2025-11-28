import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/presentation/views/chat/widget/record_widget.dart';
import 'package:lammah/presentation/views/chat/widget/video_player_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Widget _buildVideoMessage(BuildContext context) {
    final videoUrl = message['videoUrl'] ?? '';
    return VideoPlayerWidget(videoUrl: videoUrl);
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
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, color: Colors.grey),
                          SizedBox(height: 4),
                          Text(
                            'انتهت صلاحية الصورة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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

  Widget _buildFileMessage(BuildContext context) {
    final fileName = message['fileName'] ?? 'ملف';
    final fileUrl = message['fileUrl'] ?? '';

    return InkWell(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(fileUrl))) {
          await launchUrl(Uri.parse(fileUrl));
        } else {
          // عرض رسالة خطأ
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.download_for_offline, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لاختيار الأيقونة واللون
  Widget _buildStatusIcon(Map<String, dynamic> message, bool isGroup) {
    final status = message['status'];
    final List<dynamic> seenBy = message['seenBy'] ?? [];

    if (isGroup) {
      // في المجموعات: نعتبرها مقروءة إذا رآها شخص واحد على الأقل (أو يمكنك جعلها تتطلب الجميع)
      if (seenBy.isNotEmpty) {
        // يمكنك هنا إضافة منطق: لو عدد seenBy == عدد أعضاء الجروب - 1، اجعلها زرقاء
        // للتبسيط، سنعتبرها "مقروءة" إذا رآها أي شخص
        return Icon(Icons.done_all, size: 16, color: Colors.blue);
      } else {
        return Icon(Icons.check, size: 16, color: Colors.grey);
      }
    } else {
      // في الفردي: نعتمد على الـ status
      switch (status) {
        case 'sent':
          return Icon(Icons.check, size: 16, color: Colors.grey);
        case 'delivered':
          return Icon(Icons.done_all, size: 16, color: Colors.grey);
        case 'seen':
          return Icon(Icons.done_all, size: 16, color: Colors.blue);
        default:
          return Icon(Icons.access_time, size: 16, color: Colors.grey);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    final bool isEdited = message['isEdited'] ?? false;

    final bool isVideoMessage = message['type'] == 'video';

    final bool isFileMessage = message['type'] == 'file';

    bool isGroupMessage =
        message.containsKey('isGroup') ||
        message['receiverId'] == null; // طريقة تخمين

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
                child: isFileMessage
                    ? _buildFileMessage(context)
                    : isVideoMessage
                    ? _buildVideoMessage(context)
                    : isAudioMessage
                    ? _buildAudioMessage(context)
                    : (isImageMessage
                          ? _buildImageMessage(context)
                          : _buildTextMessage(context)),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.jm().format(message['date'].toDate()),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 4),
                    _buildStatusIcon(
                      message,
                      isGroupMessage,
                    ), // تمرير الرسالة كاملة
                    if (isEdited)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          '(تم التعديل)',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
