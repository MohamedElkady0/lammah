import 'package:cloud_functions/cloud_functions.dart';

Future<void> sendCallNotification(
  String receiverFcmToken,
  String callId,
  String callerName,
  String channelName,
  bool isVideoCall,
) async {
  try {
    // الحصول على مرجع للدالة التي نشرناها
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendCallNotification',
    );

    // استدعاء الدالة وإرسال البيانات
    await callable.call(<String, dynamic>{
      'receiverFcmToken': receiverFcmToken,
      'callId': callId,
      'callerName': callerName,
      'channelName': channelName,
      'isVideoCall': isVideoCall,
    });
    print("Cloud Function for call notification invoked successfully.");
  } on FirebaseFunctionsException catch (e) {
    print('Failed to call cloud function: ${e.code} - ${e.message}');
  } catch (e) {
    print('An unexpected error occurred: $e');
  }
}
