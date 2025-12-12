import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lammah/data/model/public_task.dart';

class FirestoreTasksService {
  final CollectionReference _tasksRef = FirebaseFirestore.instance.collection(
    'public_tasks',
  );

  // إضافة مهمة عامة جديدة
  Future<void> addPublicTask(PublicTask task) async {
    await _tasksRef.add(task.toMap());
  }

  // جلب المهام العامة (التي حالتها open)
  Stream<List<PublicTask>> getOpenTasks() {
    return _tasksRef
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PublicTask.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // جلب المهام الخاصة بي (التي أنشأتها)
  Stream<List<PublicTask>> getMyTasks(String myUserId) {
    return _tasksRef
        .where('ownerId', isEqualTo: myUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PublicTask.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // إضافة عرض سعر لمهمة
  Future<void> submitOffer(String taskId, TaskOffer offer) async {
    await _tasksRef.doc(taskId).collection('offers').add(offer.toMap());
  }

  // جلب العروض لمهمة محددة
  Stream<List<TaskOffer>> getOffersForTask(String taskId) {
    return _tasksRef
        .doc(taskId)
        .collection('offers')
        .orderBy('price', descending: false) // الأرخص أولاً
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskOffer.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // قبول عرض (المنطق الجوهري)
  Future<void> acceptOffer(String taskId, String offerId) async {
    // نقوم بتحديث حالة المهمة وحفظ ID العرض المقبول
    // هذا سيجعل المهمة تختفي من القائمة العامة (لأن حالتها لم تعد open)
    await _tasksRef.doc(taskId).update({
      'status': 'assigned',
      'acceptedOfferId': offerId,
    });

    // ملاحظة: لا نحتاج لحذف العروض الأخرى في قاعدة البيانات فعلياً
    // (من الأفضل الاحتفاظ بالسجلات)، لكن في الواجهة سنخفي كل شيء
    // ما عدا الشخص المقبول.
  }

  // دالة لتقييم المستخدم
  Future<void> rateUser(String userId, double rating) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      // المعادلات الحسابية للمتوسط
      double currentRating = (data['rating'] ?? 0.0).toDouble();
      int ratingCount = (data['ratingCount'] ?? 0).toInt();

      double newRating =
          ((currentRating * ratingCount) + rating) / (ratingCount + 1);

      transaction.update(userRef, {
        'rating': newRating,
        'ratingCount': ratingCount + 1,
      });
    });
  }
}
