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

  Future<void> deletePublicTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  Future<void> updatePublicTask(
    String taskId,
    Map<String, dynamic> data,
  ) async {
    await _tasksRef.doc(taskId).update(data);
  }

  Future<void> rateUser(String userId, double newRating) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) return; // حماية في حال عدم وجود المستخدم

      final data = snapshot.data() as Map<String, dynamic>;

      // 1. جلب التقييم الحالي وعدد المقيمين
      // نستخدم 0 كقيمة افتراضية إذا كان الحقل غير موجود
      double currentRating = (data['rating'] ?? 0.0).toDouble();
      int ratingCount = (data['ratingCount'] ?? 0).toInt();

      // 2. حساب المتوسط الجديد
      // المعادلة: (التقييم القديم × العدد القديم + التقييم الجديد) / (العدد القديم + 1)
      double updatedRating =
          ((currentRating * ratingCount) + newRating) / (ratingCount + 1);

      // 3. تحديث البيانات
      transaction.update(userRef, {
        'rating': updatedRating,
        'ratingCount': ratingCount + 1,
      });
    });
  }

  Future<void> acceptOffer(
    String taskId,
    String offerId,
    String workerId,
  ) async {
    // تحديث حالة المهمة + حفظ معرف العرض + حفظ معرف العامل
    await _tasksRef.doc(taskId).update({
      'status': 'assigned',
      'acceptedOfferId': offerId,
      'workerId': workerId, // <--- إضافة مهمة جداً
    });
  }

  // 1. جلب المهام التي نشرتها أنا (للمالك)
  Stream<List<PublicTask>> getMyPostedTasks(String myUid) {
    return _tasksRef
        .where('ownerId', isEqualTo: myUid)
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

  // 2. جلب المهام المسندة لي (للعامل)
  Stream<List<PublicTask>> getTasksAssignedToMe(String myUid) {
    return _tasksRef
        .where('workerId', isEqualTo: myUid) // نستخدم الحقل الجديد الذي أضفناه
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
}
