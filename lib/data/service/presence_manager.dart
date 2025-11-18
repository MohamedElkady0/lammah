import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PresenceManager extends StatefulWidget {
  final Widget child;
  const PresenceManager({super.key, required this.child});

  @override
  State<PresenceManager> createState() => _PresenceManagerState();
}

class _PresenceManagerState extends State<PresenceManager>
    with WidgetsBindingObserver {
  DatabaseReference? _presenceRef;
  StreamSubscription<User?>? _userSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // الاستماع لحالة المصادقة
    _userSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // إذا قام المستخدم بتسجيل الدخول، ابدأ في تتبع حالته
        _setupPresence(user.uid);
      } else {
        // إذا قام بتسجيل الخروج، أوقف التتبع
        _goOffline();
      }
    });
  }

  void _setupPresence(String uid) {
    _presenceRef = FirebaseDatabase.instance.ref('status/$uid');

    // تعيين onDisconnect أولاً
    _presenceRef!.onDisconnect().set({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
    });

    // ثم تعيين الحالة الحالية
    _goOnline();
  }

  void _goOnline() {
    _presenceRef?.set({'isOnline': true, 'lastSeen': ServerValue.timestamp});
  }

  void _goOffline() {
    _presenceRef?.set({'isOnline': false, 'lastSeen': ServerValue.timestamp});
    _presenceRef = null; // إعادة تعيين المرجع
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // تجاهل إذا لم يتم تسجيل دخول المستخدم بعد
    if (FirebaseAuth.instance.currentUser == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _goOnline();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _goOffline();
        break;
      case AppLifecycleState.hidden:
        // لا توجد حالة hidden في flutter_lifecycle_aware
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _userSubscription?.cancel();
    _goOffline(); // التأكد من تسجيل الخروج عند إغلاق الويدجت
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
