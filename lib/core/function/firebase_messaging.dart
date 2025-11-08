// في أعلى ملف main.dart، خارج أي كلاس

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // إذا لم يكن Firebase قد تم تهيئته، قم بذلك
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");

  // هنا يمكنك معالجة البيانات الواردة
  // في حالتنا، لا نفعل الكثير هنا لأن منطق فتح التطبيق سيتعامل معها
  // عند الضغط على الإشعار.
  // المهم هو أن الإشعار سيصل إلى الجهاز.
}
