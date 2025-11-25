import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callId;
  final String callerName;
  // ... other data

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerName,
    required channelName,
    required bool isVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$callerName يتصل بك...'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر الرفض
                IconButton(
                  icon: Icon(Icons.call_end, color: Colors.red),
                  onPressed: () async {
                    var nav = Navigator.of(context);
                    // تحديث حالة المكالمة إلى "rejected"
                    await FirebaseFirestore.instance
                        .collection('calls')
                        .doc(callId)
                        .update({'status': 'rejected'});
                    nav.pop();
                  },
                ),
                // زر القبول
                IconButton(
                  icon: Icon(Icons.call, color: Colors.green),
                  onPressed: () async {
                    // تحديث حالة المكالمة إلى "accepted"
                    await FirebaseFirestore.instance
                        .collection('calls')
                        .doc(callId)
                        .update({'status': 'accepted'});
                    // الانتقال إلى شاشة المكالمة الفعلية
                    // Navigator.pushReplacement(context, MaterialPageRoute(... -> CallScreen));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
