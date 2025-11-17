const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data, context) => {
  // التحقق من أن المستخدم مسجل دخوله
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  // استخراج البيانات المرسلة من Flutter
  const receiverFcmToken = data.receiverFcmToken;
  const notificationType = data.type; // "call" or "message"
  const senderName = data.senderName;
  const senderImage = data.senderImage; //
  let notificationTitle = "";
  let notificationBody = "";
  let dataPayload = {};

  // --- تخصيص الإشعار بناءً على نوعه ---
  if (notificationType === "call") {
    notificationTitle = `مكالمة واردة 📞 من ${senderName}`;
    notificationBody = "اضغط للرد";
    dataPayload = {
      type: "incoming_call",
      callId: data.callId,
      callerName: senderName,
      channelName: data.channelName,
      isVideoCall: String(data.isVideoCall),
    };
  } else if (notificationType === "message") {
    const messageContent = data.messageContent; // محتوى الرسالة النصية
    notificationTitle = senderName; // اسم المرسل هو العنوان
    notificationBody = messageContent;
    dataPayload = {
      type: "new_message",
      chatRoomId: data.chatRoomId, // لتوجيه المستخدم إلى المحادثة الصحيحة
      senderId: data.senderId,
    };
  } else {
    throw new functions.https.HttpsError("invalid-argument", "Invalid type");
  }

  // --- بناء حمولة الإشعار الكاملة ---
  const payload = {
    // الإشعار المرئي للمستخدم
    notification: {
      title: notificationTitle,
      body: notificationBody,
      imageUrl: senderImage, // <<< هنا نضع صورة المرسل
    },
    // البيانات التي سيقرأها التطبيق
    data: dataPayload,
    // إعدادات خاصة لأندرويد
    android: {
      priority: "high",
      notification: {
        // لجعل الصورة تظهر بشكل كبير في الإشعار على أندرويد
        imageUrl: senderImage,
      },
    },
    // إعدادات خاصة لـ iOS
    apns: {
      payload: {
        aps: {
          "mutable-content": 1, // يسمح بتعديل الإشعار لإضافة الصورة
        },
      },
      fcm_options: {
        image: senderImage, // <<< هنا أيضاً نضع صورة المرسل لـ iOS
      },
    },
  };

  try {
    // إرسال الإشعار
    await admin.messaging().sendToDevice(receiverFcmToken, payload);
    console.log("Successfully sent notification.");
    return {success: true};
  } catch (error) {
    console.error("Error sending notification:", error);
    throw new functions.https.HttpsError("internal", "Error sending");
  }
});


exports.sendFriendRequestNotification = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  }

  const senderName = data.senderName;
  const receiverFcmToken = data.receiverFcmToken;
  const senderId = context.auth.uid; // الحصول على ID المرسل بشكل آمن من context

  if (!receiverFcmToken || !senderName) {
    throw new functions.https.HttpsError("invalid-argument", "Missing required data.");
  }

  const payload = {
    notification: {
      title: "طلب صداقة جديد 💌",
      body: `${senderName} أرسل لك طلب صداقة.`,
    },
    data: {
      type: "friend_request",
      senderId: senderId,
      senderName: senderName,
      // يمكنك إضافة صورة المرسل هنا أيضاً إذا أردت
    },
    android: {
      priority: "high",
    },
  };

  try {
    await admin.messaging().sendToDevice(receiverFcmToken, payload);
    console.log(`Friend request notification sent to token: ${receiverFcmToken}`);
    return { success: true };
  } catch (error) {
    console.error("Error sending friend request notification:", error);
    throw new functions.https.HttpsError("internal", "Failed to send notification.");
  }
});