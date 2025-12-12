import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/function/firestore_tasks_service.dart';
import 'package:lammah/data/model/public_task.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/tasks/tasks_cubit.dart';
import 'package:url_launcher/url_launcher.dart'; // للاتصال وفتح الخرائط

class PublicTaskDetailsPage extends StatelessWidget {
  final PublicTask task;

  const PublicTaskDetailsPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final myAuth = context.read<AuthCubit>().state;
    String myId = '';
    // بيانات المستخدم الحالي لتقديم العرض
    String myName = '';
    String myPhone = '';
    String myLocation = '';

    if (myAuth is AuthSuccess) {
      myId = myAuth.userInfo.userId ?? '';
      myName = myAuth.userInfo.name ?? '';
      myPhone = myAuth.userInfo.phoneNumber ?? '';
      myLocation = myAuth.userInfo.userPlace ?? '';
    }

    final bool isOwner = (task.ownerId == myId);
    final bool isAssigned = (task.status == 'assigned');

    return Scaffold(
      appBar: AppBar(title: Text(task.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تفاصيل المهمة
            Text("الوصف:", style: Theme.of(context).textTheme.titleMedium),
            Text(task.description),
            const SizedBox(height: 10),
            Text(
              "الميزانية المقترحة: ${task.budget}\$",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(height: 30),

            // ============================================
            // الحالة 1: المهمة تم تعيينها لشخص (مغلقة)
            // ============================================
            if (isAssigned) ...[
              _buildAssignedView(context, isOwner, myId, task),
            ]
            // ============================================
            // الحالة 2: المهمة ما زالت مفتوحة - أنا المالك
            // ============================================
            else if (isOwner) ...[
              Text(
                "العروض المقدمة:",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<TaskOffer>>(
                stream: FirestoreTasksService().getOffersForTask(task.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final offers = snapshot.data!;
                  if (offers.isEmpty) {
                    return const Text("لا توجد عروض حتى الآن");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: offers.length,
                    itemBuilder: (ctx, index) {
                      final offer = offers[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(offer.bidderName[0]),
                          ),
                          title: Row(
                            children: [
                              Text(offer.bidderName),
                              const SizedBox(width: 8),
                              // === هنا نضيف التقييم ===
                              FutureBuilder<DocumentSnapshot>(
                                // جلب بيانات المستخدم من فايربيس للحصول على التقييم
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(offer.bidderId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  }
                                  final data =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>?;
                                  if (data == null) return const SizedBox();

                                  final rating = (data['rating'] ?? 0.0)
                                      .toDouble();
                                  return Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          subtitle: Text("السعر المقترح: ${offer.price}\$"),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // قبول العرض
                              context.read<TasksCubit>().acceptTaskOffer(
                                task.id,
                                offer.id,
                              );
                              Navigator.pop(context); // الرجوع لتحديث القائمة
                            },
                            child: const Text("قبول"),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ]
            // ============================================
            // الحالة 3: المهمة مفتوحة - أنا مستخدم (مقدم خدمة)
            // ============================================
            else ...[
              Text(
                "قدم عرضك لهذه المهمة:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.monetization_on),
                label: const Text("إرسال عرض سعر"),
                onPressed: () {
                  _showSubmitOfferDialog(
                    context,
                    task.id,
                    myId,
                    myName,
                    myPhone,
                    myLocation,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // دالة لعرض بيانات التواصل عند القبول فقط
  Widget _buildAssignedView(
    BuildContext context,
    bool isOwner,
    String myId,
    PublicTask task,
  ) {
    return StreamBuilder<List<TaskOffer>>(
      // نحتاج لجلب العرض المقبول فقط لعرض بياناته
      stream: FirestoreTasksService().getOffersForTask(task.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        // البحث عن العرض المقبول
        final acceptedOffer = snapshot.data!.firstWhere(
          (o) => o.id == task.acceptedOfferId,
          orElse: () => snapshot.data!.first, // fallback
        );

        // إذا كنت أنا المالك -> اعرض بيانات العامل
        if (isOwner) {
          return Column(
            children: [
              _contactCard(
                context,
                "تم الاتفاق مع: ${acceptedOffer.bidderName}",
                acceptedOffer.bidderPhone,
                acceptedOffer.bidderLocation,
              ),
              const SizedBox(height: 20),

              // ============ زر التقييم الجديد ============
              ElevatedButton.icon(
                icon: const Icon(Icons.star, color: Colors.amber),
                label: const Text("إنهاء المهمة وتقييم العامل"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade900,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // استدعاء الدالة هنا
                  _showRatingDialog(context, acceptedOffer.bidderId);
                },
              ),
              // =========================================
            ],
          );
        }
        // إذا كنت أنا العامل المقبول -> اعرض بيانات المالك
        else if (acceptedOffer.bidderId == myId) {
          return _contactCard(
            context,
            "صاحب المهمة: ${task.ownerName}",
            task.ownerPhone,
            task.ownerLocation,
          );
        }

        return const Center(child: Text("تم إسناد هذه المهمة لشخص آخر."));
      },
    );
  }

  Widget _contactCard(
    BuildContext context,
    String title,
    String phone,
    String location,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(100),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 50),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(phone),
            onTap: () => launchUrl(Uri.parse("tel:$phone")),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("الموقع على الخريطة"),
            // هنا نفتح رابط خرائط جوجل
            onTap: () => launchUrl(
              Uri.parse(
                "https://www.google.com/maps/search/?api=1&query=$location",
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String workerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("قيم أداء العامل"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // يمكنك استخدام مكتبة flutter_rating_bar هنا لشكل النجوم
            Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  // تغيير شكل النجمة عند الضغط يحتاج StatefulWidget،
                  // للتبسيط سنجعلها زر يرسل التقييم فوراً عند الضغط عليه
                  icon: const Icon(Icons.star, size: 40, color: Colors.amber),
                  onPressed: () {
                    context.read<TasksCubit>().rateWorker(
                      workerId,
                      index + 1.0,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("تم التقييم: ${index + 1} نجوم")),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmitOfferDialog(
    BuildContext context,
    String taskId,
    String myId,
    String name,
    String phone,
    String location,
  ) {
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تقديم عرض"),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "السعر الذي تطلبه"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final price = double.tryParse(priceController.text) ?? 0;
              if (price > 0) {
                final offer = TaskOffer(
                  id: '',
                  bidderId: myId,
                  bidderName: name,
                  bidderPhone: phone,
                  bidderLocation: location,
                  price: price,
                  createdAt: DateTime.now(),
                );
                context.read<TasksCubit>().submitOffer(taskId, offer);
                Navigator.pop(ctx);
              }
            },
            child: const Text("إرسال"),
          ),
        ],
      ),
    );
  }
}
