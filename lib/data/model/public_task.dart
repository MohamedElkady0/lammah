import 'package:cloud_firestore/cloud_firestore.dart';

class PublicTask {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerPhone; // للتواصل بعد القبول
  final String ownerLocation; // للتواصل بعد القبول
  final String title;
  final String description;
  final double budget; // السعر المبدئي
  final String status; // 'open', 'assigned', 'completed'
  final String? acceptedOfferId; // ID العرض المقبول
  final DateTime createdAt;
  final DateTime deadline;
  final String ownerImage;

  PublicTask({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerLocation,
    required this.title,
    required this.description,
    required this.budget,
    this.status = 'open',
    this.acceptedOfferId,
    required this.createdAt,
    required this.deadline,
    required this.ownerImage,
  });

  // تحويل من Firestore
  factory PublicTask.fromMap(Map<String, dynamic> data, String docId) {
    return PublicTask(
      id: docId,
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerPhone: data['ownerPhone'] ?? '',
      ownerLocation: data['ownerLocation'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      budget: (data['budget'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'open',
      acceptedOfferId: data['acceptedOfferId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deadline: (data['deadline'] as Timestamp).toDate(),
      ownerImage: data['ownerImage'] ?? '',
    );
  }

  // تحويل إلى Map للحفظ
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerLocation': ownerLocation,
      'title': title,
      'description': description,
      'budget': budget,
      'status': status,
      'acceptedOfferId': acceptedOfferId,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': Timestamp.fromDate(deadline),
      'ownerImage': ownerImage,
    };
  }
}

class TaskOffer {
  final String id;
  final String bidderId; // صاحب العرض
  final String bidderName;
  final String bidderPhone;
  final String bidderLocation;
  final double price; // السعر المقترح
  final DateTime createdAt;
  final String bidderImage;

  TaskOffer({
    required this.id,
    required this.bidderId,
    required this.bidderName,
    required this.bidderPhone,
    required this.bidderLocation,
    required this.price,
    required this.createdAt,
    required this.bidderImage,
  });

  factory TaskOffer.fromMap(Map<String, dynamic> data, String docId) {
    return TaskOffer(
      id: docId,
      bidderId: data['bidderId'] ?? '',
      bidderName: data['bidderName'] ?? '',
      bidderPhone: data['bidderPhone'] ?? '',
      bidderLocation: data['bidderLocation'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      bidderImage: data['bidderImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bidderId': bidderId,
      'bidderName': bidderName,
      'bidderPhone': bidderPhone,
      'bidderLocation': bidderLocation,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
      'bidderImage': bidderImage,
    };
  }
}
