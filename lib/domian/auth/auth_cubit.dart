import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/user_info.dart';
import 'package:lammah/data/service/auth_cache_service.dart';
import 'package:lammah/domian/upload/upload_cubit.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  //----------------variables---------------------------------------------------
  UserInfoData? _currentUserInfo;

  // Getter
  UserInfoData? get currentUserInfo => _currentUserInfo;

  // Setter (تم الإصلاح)
  set currentUserInfo(UserInfoData? userInfo) {
    _currentUserInfo = userInfo; // <--- هذا هو السطر الناقص الذي سبب المشكلة!

    // نقوم بالتحديث فقط إذا البيانات موجودة
    if (userInfo != null) {
      emit(AuthSuccess(userInfo: userInfo));
    }
  }

  //----------------------------------------------------------------------------
  bool isRegister = true;
  bool _isManualAuthProcess = false;

  String _otp = AuthString.empty;
  String get otp => _otp;
  void setOtp(String value) => _otp = value;
  String? _verificationId;
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  String _phoneNumber = AuthString.empty;
  void setPhoneNumber(String value) => _phoneNumber = value;
  String get phoneNumber => _phoneNumber;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ---------------------------------------------------------------------------

  final FirebaseAuth _credential = FirebaseAuth.instance;
  StreamSubscription? _authSubscription;
  //----------------------------------------------------------------------------
  final AuthCacheService _cacheService = AuthCacheService();
  //----------------------------------------------------------------------------
  final UploadCubit uploadCubit;
  //----------------------------------------------------------------------------
  AuthCubit({required this.uploadCubit}) : super(AuthInitial()) {
    _monitorAuthenticationState();
  }
  //----------------------------------------------------------------------------
  void _monitorAuthenticationState() {
    _authSubscription?.cancel();
    _authSubscription = _credential.authStateChanges().listen((
      User? user,
    ) async {
      if (_isManualAuthProcess) return;

      if (user != null) {
        // إذا كانت البيانات محملة بالفعل وناجحة، لا تفعل شيئاً (يمنع الوميض)
        if (state is AuthSuccess && _currentUserInfo != null) return;

        emit(AuthLoading());
        try {
          _currentUserInfo = await _cacheService.loadUserData();

          if (_currentUserInfo != null) {
            emit(AuthSuccess(userInfo: _currentUserInfo!));
          } else {
            // الكاش فارغ، نجلب من النت
            await getUserData();
          }
        } catch (e) {
          emit(AuthFailure(message: 'فشل تحميل بيانات المستخدم: $e'));
        }
      } else {
        _currentUserInfo = null;
        emit(AuthUnauthenticated());
      }
    });
  }

  //----------------------------------------------------------------------------
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  //----------------------------------------------------------------------------
  void onSignUp({
    required String name,
    required String email,
    required String password,
    required File? imageFile,
  }) async {
    if (imageFile == null) {
      emit(AuthFailure(message: AuthString.choseImg));
      return;
    }
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      emit(AuthFailure(message: AuthString.fillAllAr));
      return;
    }

    // 3. تفعيل وضع المعالجة اليدوية لمنع المراقب من التدخل
    _isManualAuthProcess = true;
    emit(AuthLoading()); // يظهر الـ Splash

    UserCredential? userCredential;

    try {
      userCredential = await _credential.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String imgUrl = await uploadCubit.uploadImageAndGetUrl(imageFile);
      String? fcmToken = await messaging.getToken();

      final userInfo = UserInfoData(
        image: imgUrl,
        email: email,
        phoneNumber: '',
        userId: _credential.currentUser!.uid,
        name: name,
        friends: [],
        userPlace: '',
        userCity: '',
        userCountry: '',
        fcmToken: fcmToken,
        friendRequestsReceived: [],
        friendRequestsSent: [],
        blockedUsers: [],
        points: 0,
        adsCount: 0,
        language: '',
        followers: [],
        following: [],
        latitude: 0.0,
        longitude: 0.0,
      );

      // حفظ البيانات في قاعدة البيانات
      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .set(userInfo.toJson());

      // حفظ في الكاش وتحديث المتغير
      _currentUserInfo = userInfo;
      await _cacheService.saveUserData(_currentUserInfo!);

      // إرسال النجاح
      emit(AuthSuccess(userInfo: _currentUserInfo!));
    } on FirebaseAuthException catch (e) {
      if (userCredential?.user != null) {
        await userCredential?.user?.delete();
      }
      String message = AuthString.errAuth1;
      if (e.code == AuthString.emailAlready) {
        message = AuthString.errAuth2;
      } else if (e.code == AuthString.weakPass) {
        message = AuthString.errAuth3;
      }
      emit(AuthFailure(message: message));
    } catch (e) {
      if (userCredential != null) {
        await userCredential.user?.delete();
      }
      emit(AuthFailure(message: 'فشل إكمال التسجيل: ${e.toString()}'));
    } finally {
      // 4. إعادة المتغير لوضعه الطبيعي في كل الأحوال (نجاح أو فشل)
      _isManualAuthProcess = false;
    }
  }

  //----------------------------------------------------------------------------
  void onSignIn({required String email, required String password}) async {
    // 3. تفعيل وضع المعالجة اليدوية لمنع المراقب من التدخل
    _isManualAuthProcess = true;
    emit(AuthLoading());
    try {
      await _credential.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        _currentUserInfo = UserInfoData.fromJson(userDoc.data()!);
        emit(AuthSuccess(userInfo: _currentUserInfo!));
      } else {
        emit(AuthFailure(message: AuthString.userDoesNotExist));
        return;
      }
    } on FirebaseAuthException {
      emit(AuthFailure(message: AuthString.errAuth4));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    } finally {
      // 4. إعادة المتغير لوضعه الطبيعي في كل الأحوال (نجاح أو فشل)
      _isManualAuthProcess = false;
    }
  }

  //----------------------------------------------------------------------------
  signInWithGoogle() async {
    _isManualAuthProcess = true;
    emit(AuthLoading());
    try {
      // 1. بدء عملية تسجيل الدخول بجوجل
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthFailure(message: AuthString.googleSignInCancelled));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 2. الحصول على بيانات المستخدم من Firebase Auth
      final UserCredential userCredential = await _credential
          .signInWithCredential(credential);

      final User user = userCredential.user!;
      String? fcmToken = await messaging.getToken();

      // 3. التحقق من وجود المستخدم في Firestore
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // --- الحالة الأولى: المستخدم موجود مسبقاً ---
        // نقوم بتحويل البيانات القادمة من Firestore إلى موديل UserInfoData
        // (ملاحظة: تأكد أن لديك دالة fromJson في الموديل)
        Map<String, dynamic> docData = userDoc.data() as Map<String, dynamic>;

        // تحديث الـ FCM Token لضمان وصول الإشعارات على الجهاز الجديد
        docData['fcmToken'] = fcmToken;

        // تحديث التوكن في فايربيس أيضاً
        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(user.uid)
            .update({'fcmToken': fcmToken});

        _currentUserInfo = UserInfoData.fromJson(docData);
      } else {
        // --- الحالة الثانية: مستخدم جديد ---
        // ننشئ كائن جديد ببيانات جوجل
        UserInfoData newUserInfo = UserInfoData(
          userId: user.uid,
          name: user.displayName ?? AuthString.empty,
          email: user.email ?? AuthString.empty,
          phoneNumber: user.phoneNumber ?? AuthString.empty,
          image: user.photoURL ?? AuthString.empty,
          // هنا نضع القوائم فارغة لأن المستخدم جديد
          friends: [],
          userPlace: '',
          userCity: '',
          userCountry: '',
          fcmToken: fcmToken,
          friendRequestsReceived: [],
          friendRequestsSent: [],
          blockedUsers: [],
          points: 0,
          adsCount: 0,
          language: '',
          followers: [],
          following: [],
          latitude: 0.0,
          longitude: 0.0,
        );

        // حفظ المستخدم الجديد في Firestore
        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(user.uid)
            .set(newUserInfo.toJson());

        _currentUserInfo = newUserInfo;
      }

      // 4. خطوة مشتركة: حفظ البيانات في الكاش وإرسال حالة النجاح
      if (_currentUserInfo != null) {
        await _cacheService.saveUserData(_currentUserInfo!);
        emit(AuthSuccess(userInfo: _currentUserInfo!));
      } else {
        emit(AuthFailure(message: "حدث خطأ أثناء معالجة بيانات المستخدم"));
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        emit(AuthFailure(message: e.message ?? AuthString.googleSignInFailed));
      } else {
        emit(AuthFailure(message: 'فشل تسجيل الدخول: ${e.toString()}'));
      }
    } finally {
      _isManualAuthProcess = false; // إعادة المتغير
    }
  }
  //----------------------------------------------------------------------------
  // Future<void> signInWithFacebook() async {
  //     // 3. تفعيل وضع المعالجة اليدوية لمنع المراقب من التدخل
  //     _isManualAuthProcess = true;
  //     emit(AuthLoading());
  //     try {
  //       // 1. طلب تسجيل الدخول من فيسبوك
  //       final LoginResult loginResult = await FacebookAuth.instance.login();

  //       if (loginResult.status == LoginStatus.success) {
  //         final AccessToken accessToken = loginResult.accessToken!;

  //         final OAuthCredential credential =
  //             FacebookAuthProvider.credential(accessToken.tokenString);

  //         // 2. تسجيل الدخول في فيربايس
  //         final UserCredential userCredential =
  //             await _credential.signInWithCredential(credential);

  //         if (userCredential.user != null) {
  //           // 3. استخدام الدالة الموحدة (التي كتبناها سابقاً)
  //           // هذه الدالة ذكية: إذا المستخدم موجود تجلب بياناته، وإذا جديد تنشئه
  //           await _fetchOrCreateUser(userCredential.user!);
  //         } else {
  //            emit(AuthFailure(message: "فشل استرجاع بيانات المستخدم من فيسبوك"));
  //         }

  //       } else if (loginResult.status == LoginStatus.cancelled) {
  //         emit(AuthFailure(message: "تم إلغاء تسجيل الدخول"));
  //       } else {
  //         emit(AuthFailure(message: "خطأ في فيسبوك: ${loginResult.message}"));
  //       }
  //     } on FirebaseAuthException catch (e) {
  //        // معالجة أخطاء فيربايس (مثل تضارب البريد الإلكتروني مع حساب جوجل)
  //        if (e.code == 'account-exists-with-different-credential') {
  //          emit(AuthFailure(message: "هذا البريد الإلكتروني مسجل مسبقاً بطريقة أخرى (جوجل أو كلمة مرور)"));
  //        } else {
  //          emit(AuthFailure(message: e.message ?? "فشل تسجيل الدخول"));
  //        }
  //     } catch (e) {
  //       emit(AuthFailure(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
  //     } finally {
  // 4. إعادة المتغير لوضعه الطبيعي في كل الأحوال (نجاح أو فشل)
  // _isManualAuthProcess = false;
  // }
  //   }
  //----------------------------------------------------------------------------
  // 1. دالة مساعدة خاصة لمعالجة البيانات بعد تسجيل الدخول
  // هذه الدالة تضمن عدم تكرار الكود وتستخدم في المكانين
  Future<void> _fetchOrCreateUser(User user) async {
    // 3. تفعيل وضع المعالجة اليدوية لمنع المراقب من التدخل
    _isManualAuthProcess = true;
    try {
      String? fcmToken = await messaging.getToken();

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // --- المستخدم موجود مسبقاً ---
        Map<String, dynamic> docData = userDoc.data() as Map<String, dynamic>;

        // تحديث التوكن
        if (fcmToken != null) {
          docData['fcmToken'] = fcmToken;
          await FirebaseFirestore.instance
              .collection(AuthString.fSUsers)
              .doc(user.uid)
              .update({'fcmToken': fcmToken});
        }

        _currentUserInfo = UserInfoData.fromJson(docData);
      } else {
        // --- مستخدم جديد ---
        // نستخدم رقم الهاتف القادم من Firebase مباشرة لضمان صحته
        String phone = user.phoneNumber ?? _phoneNumber;

        UserInfoData newUserInfo = UserInfoData(
          userId: user.uid,
          phoneNumber: phone,
          // البيانات الأخرى تكون فارغة أو افتراضية
          name: AuthString.empty,
          email: AuthString.empty,
          image: AuthString.empty,
          friends: [],
          userPlace: '',
          userCity: '',
          userCountry: '',
          fcmToken: fcmToken,
          friendRequestsReceived: [],
          friendRequestsSent: [],
          blockedUsers: [],
          points: 0,
          adsCount: 0,
          language: '',
          followers: [],
          following: [],
          latitude: 0.0,
          longitude: 0.0,
        );

        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(user.uid)
            .set(newUserInfo.toJson());

        _currentUserInfo = newUserInfo;
      }

      // حفظ في الكاش وإرسال حالة النجاح
      if (_currentUserInfo != null) {
        await _cacheService.saveUserData(_currentUserInfo!);
        emit(AuthSuccess(userInfo: _currentUserInfo!));
      }
    } catch (e) {
      emit(AuthFailure(message: "فشل جلب بيانات المستخدم: $e"));
    } finally {
      // 4. إعادة المتغير لوضعه الطبيعي في كل الأحوال (نجاح أو فشل)
      _isManualAuthProcess = false;
    }
  }

  // ---------------------------------------------------------------------------

  void sendOtp() async {
    emit(AuthLoading());
    await FirebaseAuth.instance.verifyPhoneNumber(
      // داخل sendOtp
      verificationCompleted: (PhoneAuthCredential credential) async {
        // 1. تفعيل الحماية
        _isManualAuthProcess = true;
        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);

          if (userCredential.user != null) {
            await _fetchOrCreateUser(userCredential.user!);
          }
        } catch (e) {
          emit(AuthFailure(message: "فشل التحقق التلقائي: $e"));
        } finally {
          // 2. إغلاق الحماية
          _isManualAuthProcess = false;
        }
      },

      verificationFailed: (FirebaseAuthException e) {
        String msg = "فشل التحقق";
        if (e.code == 'invalid-phone-number') msg = "رقم الهاتف غير صحيح";
        emit(AuthFailure(message: "$msg: ${e.message}"));
      },

      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        emit(AuthCodeSentSuccess());
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // ---------------------------------------------------------------------------

  void verifyOtp() async {
    if (_verificationId == null) {
      emit(
        AuthFailure(message: AuthString.noOTP),
      ); // تأكد من الرسالة "لم يتم إرسال كود"
      return;
    }
    if (_otp.isEmpty) {
      emit(
        AuthFailure(message: AuthString.otpVerificationFailed),
      ); // رسالة "أدخل الكود"
      return;
    }
    // 3. تفعيل وضع المعالجة اليدوية لمنع المراقب من التدخل
    _isManualAuthProcess = true;
    emit(AuthLoading());

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otp,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        // الحالة 2: التحقق اليدوي عبر إدخال الكود
        // نستخدم نفس الدالة المساعدة لضمان نفس المنطق
        await _fetchOrCreateUser(userCredential.user!);
      } else {
        emit(AuthFailure(message: AuthString.noUser));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        emit(
          AuthFailure(message: AuthString.invalidVerificationCode),
        ); // "الكود غير صحيح"
      } else if (e.code == 'session-expired') {
        emit(AuthFailure(message: "انتهت صلاحية الجلسة، اطلب الكود مرة أخرى"));
      } else {
        emit(AuthFailure(message: e.message ?? "فشل التحقق"));
      }
    } catch (e) {
      emit(AuthFailure(message: "حدث خطأ: ${e.toString()}"));
    } finally {
      // 4. إعادة المتغير لوضعه الطبيعي في كل الأحوال (نجاح أو فشل)
      _isManualAuthProcess = false;
    }
  }

  //----------------------------------------------------------------------------
  void getPhoneNumber(String phoneNumber) async {
    try {
      number = await PhoneNumber.getRegionInfoFromPhoneNumber(
        phoneNumber,
        AuthString.getPhoneN,
      );
    } catch (e) {
      emit(AuthFailure(message: 'فشل الحصول على معلومات الهاتف: $e'));
    }
  }

  //----------------------------------------------------------------------------
  void forgetPassword({required String email}) async {
    emit(AuthLoading());

    try {
      await _credential.sendPasswordResetEmail(email: email);
      emit(
        ForGetPasswordSuccess(
          message: 'تم إرسال بريد إعادة تعيين كلمة المرور إلى $email',
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == AuthString.emailNotFound) {
        emit(AuthFailure(message: AuthString.noEmail));
      } else {
        emit(
          AuthFailure(
            message: 'فشل إرسال بريد إعادة تعيين كلمة المرور: ${e.message}',
          ),
        );
      }
    } catch (e) {
      emit(AuthFailure(message: 'خطأ غير متوقع: ${e.toString()}'));
    }
  }

  //----------------------------------------------------------------------------
  void signOut() async {
    emit(AuthLoading());

    try {
      await _credential.signOut();

      await _googleSignIn.signOut();
      await _cacheService.clearUserData();

      _currentUserInfo = null;
      emit(AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------------------
  void changeRegister() {
    isRegister = !isRegister;
    emit(AuthInitial());
  }

  //----------------------------------------------------------------------------
  Future<void> getUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        // نستخدم المتغير الخاص _currentUserInfo مباشرة ونحفظ فيه البيانات
        _currentUserInfo = UserInfoData.fromJson(
          doc.data() as Map<String, dynamic>,
        );

        // ثم نقوم بتحديث الـ Cache للأمان
        await _cacheService.saveUserData(_currentUserInfo!);

        // وأخيراً نحدث الواجهة
        emit(AuthSuccess(userInfo: _currentUserInfo!));
      } else {
        // إذا المستخدم موجود في Auth ولكن ليس له بيانات في Firestore
        emit(
          AuthFailure(
            message:
                "بيانات المستخدم غير موجودة، يرجى التواصل مع الدعم أو التسجيل مجدداً.",
          ),
        );
      }
    } catch (e) {
      print("Error getting user data: $e");
      emit(AuthFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------------------
  // داخل AuthCubit
  void updateLocalUser(UserInfoData newUser) {
    currentUserInfo = newUser;
    emit(
      AuthSuccess(userInfo: newUser),
    ); // هذا السطر سيجعل الواجهة تعيد بناء نفسها بالبيانات الجديدة
  }
}
