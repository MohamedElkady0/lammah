import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // للنسخ
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lammah/core/config/config_app.dart';
import 'package:lammah/presentation/views/chat/widget/record_widget.dart';
import 'package:lammah/presentation/views/chat/widget/video_player_widget.dart';
import 'package:lammah/domian/chat/chat_cubit.dart'; // تأكد من المسار الصحيح للـ Cubit
import 'package:url_launcher/url_launcher.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    required this.message,
    required this.isFriend,
    required this.isGroupChat, // إضافة مهمة لمنطق المجموعات
    required this.chatId, // ضروري لعمليات الحذف والتعديل
  });

  final Map<String, dynamic> message;
  final bool isFriend;
  final bool isGroupChat;
  final String chatId;

  // --- دوال بناء الواجهة (Text, Audio, etc.) بقيت كما هي تقريباً ---

  Widget _buildTextMessage(BuildContext context) {
    return Text(
      message['message'] ?? '',
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: isFriend ? Colors.black : Colors.white, // تحسين اللون
      ),
    );
  }

  // داخل ChatWidget.dart

  Widget _buildAudioMessage(BuildContext context) {
    final String audioUrl = message['audioUrl'] ?? '';
    final int duration = message['duration'] ?? 0;

    if (audioUrl.isEmpty) {
      return Text(
        'لا يمكن تشغيل الرسالة',
        style: TextStyle(color: isFriend ? Colors.black : Colors.white),
      );
    }

    return AudioPlayerWidget(
      audioUrl: audioUrl,
      durationInMillis: duration,
      // تمرير اللون: أسود إذا كان صديق (خلفية فاتحة)، أبيض إذا كنت أنا (خلفية زرقاء)
      contentColor: isFriend ? Colors.black87 : Colors.white,
    );
  }

  Widget _buildVideoMessage(BuildContext context) {
    final videoUrl = message['videoUrl'] ?? '';
    return VideoPlayerWidget(videoUrl: videoUrl);
  }

  Widget _buildImageMessage(BuildContext context) {
    final List<dynamic> imageUrls = message['imageUrls'] ?? [];
    final String caption = message['caption'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          itemCount: imageUrls.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: imageUrls.length > 1 ? 2 : 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            );
          },
        ),
        if (caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              caption,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isFriend ? Colors.black : Colors.white,
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
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName,
                style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.download, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // تعديل مهم: إظهار الأيقونة فقط لرسائلي أنا
  Widget _buildStatusIcon(Map<String, dynamic> message) {
    // إذا كانت الرسالة من صديق (isFriend == true)، لا نعرض حالة القراءة
    if (isFriend) return const SizedBox.shrink();

    final status = message['status'];
    final List<dynamic> seenBy = message['seenBy'] ?? [];

    if (isGroupChat) {
      if (seenBy.isNotEmpty) {
        return const Icon(Icons.done_all, size: 16, color: Colors.blue);
      } else {
        return const Icon(Icons.check, size: 16, color: Colors.grey);
      }
    } else {
      switch (status) {
        case 'sent':
          return const Icon(Icons.check, size: 16, color: Colors.grey);
        case 'delivered':
          return const Icon(Icons.done_all, size: 16, color: Colors.grey);
        case 'seen':
          return const Icon(Icons.done_all, size: 16, color: Colors.blue);
        default:
          return const Icon(Icons.access_time, size: 16, color: Colors.grey);
      }
    }
  }

  // قائمة الخيارات (تعديل/حذف) ربطاً بالـ Cubit
  void _showMessageOptions(BuildContext context) {
    // لا نسمح بحذف أو تعديل رسائل الآخرين
    if (isFriend) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              // خيار التعديل (فقط للنصوص)
              if (message['type'] == 'text')
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('تعديل الرسالة'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditDialog(context);
                  },
                ),
              // خيار الحذف
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'حذف الرسالة',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  // استدعاء الـ Cubit للحذف
                  context.read<ChatCubit>().deleteMessage(
                    messageId: message['messageId'],
                    uId: isGroupChat
                        ? chatId
                        : message['receiverId'], // انتبه هنا لمنطق الـ ID
                    // ملاحظة: دالة deleteMessage في الـ Cubit الحالي تعتمد على chatRoomId(uid)
                    // إذا كانت مجموعة، قد تحتاج لتعديل بسيط في استدعاء الدالة لتقبل chatId مباشرة
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('نسخ'),
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: message['message'] ?? ''),
                  );
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController editController = TextEditingController(
      text: message['message'],
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تعديل الرسالة"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: "أدخل التعديل"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                // استدعاء الـ Cubit للتعديل
                context.read<ChatCubit>().editMessageText(
                  newText: editController.text,
                  messageId: message['messageId'],
                  uId: isGroupChat ? chatId : message['receiverId'],
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ConfigApp.initConfig(context);
    final bool isEdited = message['isEdited'] ?? false;
    final String type = message['type'] ?? 'text';

    return Align(
      alignment: isFriend ? Alignment.centerLeft : Alignment.centerRight,
      child: InkWell(
        onLongPress: () => _showMessageOptions(context), // تفعيل القائمة
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: isFriend
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: ConfigApp.width * 0.75),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // تغيير الألوان لتمييز المرسل (أزرق) عن المستقبل (رمادي/أبيض)
                  color: isFriend ? Colors.grey[300] : Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isFriend
                        ? Radius.zero
                        : const Radius.circular(16),
                    bottomRight: isFriend
                        ? const Radius.circular(16)
                        : Radius.zero,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (type == 'file') _buildFileMessage(context),
                    if (type == 'video') _buildVideoMessage(context),
                    if (type == 'audio') _buildAudioMessage(context),
                    if (type == 'image') _buildImageMessage(context),
                    if (type == 'text') _buildTextMessage(context),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isFriend
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Text(
                    DateFormat.jm().format(message['date'].toDate()),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (isEdited)
                    const Text(
                      ' (معدل)',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  const SizedBox(width: 4),
                  // عرض الأيقونة فقط إذا لم تكن رسالة صديق
                  _buildStatusIcon(message),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
