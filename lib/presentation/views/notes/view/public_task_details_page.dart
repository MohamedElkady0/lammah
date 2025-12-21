import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/function/firestore_tasks_service.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/public_task.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:lammah/domian/tasks/tasks_cubit.dart';
import 'package:lammah/presentation/views/chat/views/chat_send_res.dart';
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
    String myImage = '';

    if (myAuth is AuthSuccess) {
      myId = myAuth.userInfo.userId ?? '';
      myName = myAuth.userInfo.name ?? '';
      myPhone = myAuth.userInfo.phoneNumber ?? '';
      myLocation = myAuth.userInfo.userPlace ?? '';
      myImage = myAuth.userInfo.image ?? '';
    }

    final bool isOwner = (task.ownerId == myId);
    final bool isAssigned = (task.status == 'assigned');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          'قدم عرضك',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تفاصيل المهمة
            Text(
              "الوصف:",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              task.description,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "العروض المقدمة:",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
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
                    return Center(
                      child: Text(
                        "لا توجد عروض حتى الآن",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: offers.length,
                    itemBuilder: (ctx, index) {
                      final offer = offers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: offer.bidderImage.isNotEmpty
                                ? NetworkImage(offer.bidderImage)
                                : null,
                            child: offer.bidderImage.isEmpty
                                ? Text(offer.bidderName[0])
                                : null,
                          ),
                          title: Row(
                            children: [
                              Text(
                                offer.bidderName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // ==== جلب وعرض التقييم ====
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection(AuthString.fSUsers)
                                    .doc(offer.bidderId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return const SizedBox(); // تحميل أو لا يوجد تقييم
                                  }
                                  final userData =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>;
                                  final rating = (userData['rating'] ?? 0.0)
                                      .toDouble();

                                  if (rating == 0) {
                                    return const SizedBox(); // لا يوجد تقييم سابق
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withAlpha(100),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.orange,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          subtitle: Text("السعر المقترح: ${offer.price}\$"),

                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () async {
                              // 1. قبول العرض
                              await context.read<TasksCubit>().acceptTaskOffer(
                                task.id,
                                offer.id,
                              );

                              // 2. إنشاء ChatRoomId موحد

                              String chatRoomId = getChatRoomId(
                                myId,
                                offer.bidderId,
                              );

                              if (context.mounted) {
                                // 3. الانتقال لشاشة الدردشة بالبيانات الحقيقية
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SendResChat(
                                      userName:
                                          offer.bidderName, // اسم مقدم العرض
                                      userImage: offer.bidderImage.isNotEmpty
                                          ? offer.bidderImage
                                          : "https://cdn-icons-png.flaticon.com/512/149/149071.png", // صورة احتياطية
                                      uid: offer.bidderId,
                                      isGroupChat: false,
                                      chatId: chatRoomId,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text("قبول ومراسلة"),
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
                    myImage,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String workerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تقييم الأداء"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("كيف كان أداء العامل في هذه المهمة؟"),
            const SizedBox(height: 20),
            // صف من النجوم
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 5,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(Icons.star, size: 32, color: Colors.amber),
                  onPressed: () {
                    // إرسال التقييم (index + 1 لأن العد يبدأ من 0)
                    context.read<TasksCubit>().rateWorker(
                      workerId,
                      (index + 1).toDouble(),
                    );

                    Navigator.pop(context); // إغلاق النافذة

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("تم إرسال تقييم ${index + 1} نجوم"),
                      ),
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

  // دالة لعرض بيانات التواصل عند القبول فقط
  Widget _buildAssignedView(
    BuildContext context,
    bool isOwner,
    String myId,
    PublicTask task,
  ) {
    return StreamBuilder<List<TaskOffer>>(
      stream: FirestoreTasksService().getOffersForTask(task.id),
      builder: (context, snapshot) {
        // حماية إضافية: التأكد من وجود بيانات وأن القائمة ليست فارغة
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        // البحث عن العرض المقبول
        final acceptedOffer = snapshot.data!.firstWhere(
          (o) => o.id == task.acceptedOfferId,
          orElse: () => snapshot.data!.first,
        );

        // ====================================================
        // الحالة 1: أنا المالك (أرى بيانات العامل + تقييم + شات)
        // ====================================================
        if (isOwner) {
          return Column(
            children: [
              _contactCard(
                context,
                "تم الاتفاق مع: ${acceptedOffer.bidderName}",
                acceptedOffer.bidderPhone,
                acceptedOffer.bidderLocation,
              ),
              const SizedBox(height: 15),

              // زر مراسلة العامل
              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text("مراسلة العامل"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  String chatRoomId = getChatRoomId(
                    myId,
                    acceptedOffer.bidderId,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendResChat(
                        userName: acceptedOffer.bidderName,
                        // هنا التعديل: استخدام الصورة الحقيقية إذا وجدت
                        userImage: acceptedOffer.bidderImage.isNotEmpty
                            ? acceptedOffer.bidderImage
                            : "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                        uid: acceptedOffer.bidderId,
                        isGroupChat: false,
                        chatId: chatRoomId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // زر التقييم وإنهاء المهمة
              OutlinedButton.icon(
                icon: const Icon(Icons.star_rate_rounded, color: Colors.amber),
                label: const Text("إنهاء المهمة وتقييم العامل"),
                onPressed: () {
                  _showRatingDialog(context, acceptedOffer.bidderId);
                },
              ),
            ],
          );
        }
        // ====================================================
        // الحالة 2: أنا العامل المقبول (أرى بيانات المالك + شات)
        // ====================================================
        else if (acceptedOffer.bidderId == myId) {
          return Column(
            children: [
              _contactCard(
                context,
                "صاحب المهمة: ${task.ownerName}",
                task.ownerPhone,
                task.ownerLocation,
              ),
              const SizedBox(height: 15),

              // زر مراسلة صاحب المهمة (أضفناه هنا أيضاً)
              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text("مراسلة صاحب المهمة"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  String chatRoomId = getChatRoomId(myId, task.ownerId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendResChat(
                        userName: task.ownerName,
                        userImage: task.ownerImage,
                        uid: task.ownerId,
                        isGroupChat: false,
                        chatId: chatRoomId,
                      ),
                    ),
                  );
                },
              ),
            ],
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

  void _showSubmitOfferDialog(
    BuildContext context,
    String taskId,
    String myId,
    String name,
    String phone,
    String location,
    String image,
  ) {
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          "تقديم عرض",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: TextField(
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "السعر الذي تطلبه",
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final price = double.tryParse(priceController.text) ?? 0;

              // جلب بيانات المستخدم الحالية
              final authState = context.read<AuthCubit>().state;

              if (price > 0 && authState is AuthSuccess) {
                // الوصول لبيانات المستخدم الكاملة
                final myUser = authState.userInfo; // هذا هو UserInfoData

                final offer = TaskOffer(
                  id: '',
                  bidderId: myUser.userId ?? '',
                  bidderName: myUser.name ?? '',
                  bidderImage:
                      myUser.image ?? '', // <--- نرسل الصورة الحقيقية هنا
                  bidderPhone: myUser.phoneNumber ?? '',
                  bidderLocation: myUser.userCity ?? '',
                  price: price,
                  createdAt: DateTime.now(),
                );

                context.read<TasksCubit>().submitOffer(taskId, offer);
                Navigator.pop(ctx);
              }
            },

            child: Text(
              "إرسال",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  String getChatRoomId(String user1, String user2) {
    if (user1.hashCode <= user2.hashCode) {
      return '$user1-$user2';
    } else {
      return '$user2-$user1';
    }
  }
}
