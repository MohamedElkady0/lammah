import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video, file, call }

class MessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String message; // Text content or Caption
  final String type; // 'text', 'image', 'video', 'file'
  final Timestamp date;
  final List<String>? imageUrls;
  final String? videoUrl;
  final String? fileUrl;
  final String? fileName;
  final bool isEdited;
  final String? status;
  final List<String>? seenBy;

  MessageModel({
    this.status,
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.date,
    this.message = '',
    this.type = 'text',
    this.imageUrls,
    this.videoUrl,
    this.fileUrl,
    this.fileName,
    this.isEdited = false,
    this.seenBy,
  });

  // تحويل البيانات إلى Map لإرسالها إلى Firebase
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'message': message,
      'type': type,
      'date': date,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'isEdited': isEdited,
      'status': status,
      'seenBy': [],
    };
  }

  // استقبال البيانات من Firebase
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImage: map['senderImage'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'text',
      date: map['date'] ?? Timestamp.now(),
      imageUrls: map['imageUrls'] != null
          ? List<String>.from(map['imageUrls'])
          : null,
      videoUrl: map['videoUrl'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      isEdited: map['isEdited'] ?? false,
      status: map['status'],
      seenBy: map['seenBy'] != null ? List<String>.from(map['seenBy']) : null,
    );
  }
}
