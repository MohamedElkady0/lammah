const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// هذه هي الدالة التي سيستدعيها تطبيق Flutter
exports.sendCallNotification = functions.https.onCall(async (data, context) => {
  // التحقق من أن المستخدم الذي يستدعي الدالة مسجل دخوله
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated.",
    );
  }

  // استخراج البيانات المرسلة من Flutter
  const receiverFcmToken = data.receiverFcmToken;
  const callId = data.callId;
  const callerName = data.callerName;
  const channelName = data.channelName;
  const isVideoCall = data.isVideoCall;

  console.log(`Attempting to send a call notification to token: ${receiverFcmToken}`);

  // إنشاء حمولة الإشعار (Notification Payload)
  const payload = {
    // الإشعار الذي سيراه المستخدم
    notification: {
      title: "مكالمة واردة 📞",
      body: `${callerName} يتصل بك...`,
    },
    // البيانات المخصصة التي سيقرأها تطبيقك
    data: {
      type: "incoming_call",
      callId: callId,
      callerName: callerName,
      channelName: channelName,
      isVideoCall: String(isVideoCall),
    },
    // إعدادات خاصة لضمان وصول الإشعار بسرعة (مهم للمكالمات)
    android: {
      priority: "high",
    },
    apns: {
      payload: {
        aps: {
          contentAvailable: true,
        },
      },
      headers: {
        "apns-push-type": "voip", // استخدام إشعارات VoIP لـ iOS (يتطلب إعدادات إضافية)
        "apns-priority": "10",
      },
    },
  };

  try {
    // إرسال الإشعار
    await admin.messaging().sendToDevice(receiverFcmToken, payload);
    console.log("Successfully sent call notification.");
    return {success: true};
  } catch (error) {
    console.error("Error sending notification:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error sending notification",
    );
  }
});