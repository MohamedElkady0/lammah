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

import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  //----------------variables---------------------------------------------------
  UserInfoData? _currentUserInfo;
  UserInfoData? get currentUserInfo => _currentUserInfo;
  set currentUserInfo(UserInfoData? userInfo) {
    emit(AuthSuccessSetUserInfo(userInfo: userInfo!));
  }

  //----------------------------------------------------------------------------
  bool isRegister = true;
  File? img;
  String _otp = AuthString.empty;
  String get otp => _otp;
  void setOtp(String value) => _otp = value;
  String? _verificationId;
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  String _phoneNumber = AuthString.empty;
  void setPhoneNumber(String value) => _phoneNumber = value;
  String get phoneNumber => _phoneNumber;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  SharedPreferences? prefs;
  final UploadCubit uploadCubit = UploadCubit();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ---------------------------------------------------------------------------

  final FirebaseAuth _credential = FirebaseAuth.instance;
  StreamSubscription? _authSubscription;
  //----------------------------------------------------------------------------
  final AuthCacheService _cacheService = AuthCacheService();
  //----------------------------------------------------------------------------
  AuthCubit() : super(AuthInitial()) {
    _monitorAuthenticationState();
  }
  //----------------------------------------------------------------------------
  void _monitorAuthenticationState() {
    _authSubscription?.cancel();
    _authSubscription = _credential.authStateChanges().listen((
      User? user,
    ) async {
      if (user != null) {
        emit(AuthLoading());
        try {
          _currentUserInfo ??= await _cacheService.loadUserData();
          emit(AuthSuccess(userInfo: _currentUserInfo!));
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
  }) async {
    if (img == null) {
      emit(AuthFailure(message: AuthString.choseImg));
      return;
    }
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      emit(AuthFailure(message: AuthString.fillAllAr));
      return;
    }

    emit(AuthLoading());

    UserCredential? userCredential;

    try {
      final String imgUrl = await uploadCubit.uploadImageAndGetUrl(img!);
      userCredential = await _credential.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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
      );

      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .set(userInfo.toJson());
      if (_currentUserInfo == null) {
        _currentUserInfo = userInfo;
        await _cacheService.saveUserData(_currentUserInfo!);
      }

      emit(AuthSuccess(userInfo: _currentUserInfo!));
    } on FirebaseAuthException catch (e) {
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
    }
  }

  //----------------------------------------------------------------------------
  void onSignIn({required String email, required String password}) async {
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
    }
  }

  //----------------------------------------------------------------------------
  signInWithGoogle() async {
    emit(AuthLoading());
    try {
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

      final UserCredential userCredential = await _credential
          .signInWithCredential(credential);

      String? fcmToken = await messaging.getToken();
      UserInfoData userInfo = UserInfoData(
        userId: _credential.currentUser!.uid,
        name: userCredential.user!.displayName ?? AuthString.empty,
        email: userCredential.user!.email ?? AuthString.empty,
        phoneNumber: userCredential.user!.phoneNumber ?? AuthString.empty,
        image: userCredential.user!.photoURL ?? AuthString.empty,
        friends: _currentUserInfo?.friends ?? [],
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
      );

      final userDoc = await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(userCredential.user!.uid)
            .update(userInfo.toJson());
      } else {
        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(userCredential.user!.uid)
            .set(userInfo.toJson());
      }
      if (_currentUserInfo == null) {
        _currentUserInfo = userInfo;
        await _cacheService.saveUserData(_currentUserInfo!);
      }
      emit(AuthSuccess(userInfo: _currentUserInfo!));
    } catch (e) {
      if (e is FirebaseAuthException) {
        emit(AuthFailure(message: e.message ?? AuthString.googleSignInFailed));
      } else {
        emit(AuthFailure(message: 'خطأ غير معروف: ${e.toString()}'));
      }
    }
  }
  //----------------------------------------------------------------------------
  //   Future<User?> signInWithFacebook() async {
  //     emit(AuthLoading());
  //     try {
  //       final LoginResult loginResult = await _facebookAuthResult.login();

  //       if (loginResult.status == LoginStatus.success) {
  //         final AccessToken accessToken = loginResult.accessToken!;
  //         final OAuthCredential credentialAuth =
  //             FacebookAuthProvider.credential(accessToken.tokenString);
  //         final UserCredential userCredential =
  //             await _credential.signInWithCredential(credentialAuth);

  // UserInfoData userInfo = UserInfoData(
  //   userId: userCredential.user!.uid,
  //   name: userCredential.user!.displayName ?? '',
  //   email: userCredential.user!.email ?? '',
  //   phoneNumber: userCredential.user!.phoneNumber ?? '',
  //   image: userCredential.user!.photoURL ?? '',
  //   friends: _currentUserInfo?.friends ?? [],
  //   userPlace: '${currentPosition?.latitude}-${currentPosition?.longitude}',
  //   userCity:
  //       '${currentAddress.split(',')[1]}-${currentAddress.split(',')[2]}',
  //   userCountry: currentAddress.split(',')[0],
  // );

  //         final userDoc = await FirebaseFirestore.instance
  //             .collection('Users')
  //             .doc(userCredential.user!.uid)
  //             .get();

  //         if (userDoc.exists) {

  //           await FirebaseFirestore.instance
  //               .collection('Users')
  //               .doc(userCredential.user!.uid)
  //               .update(userInfo.toJson());
  //         } else {

  //           await FirebaseFirestore.instance
  //               .collection('Users')
  //               .doc(userCredential.user!.uid)
  //               .set(userInfo.toJson());
  //         }
  //         _currentUserInfo = userInfo;
  //         emit(AuthSuccess());
  //         return userCredential.user;
  //       } else {
  //         emit(AuthFailure(
  //             message: 'خطأ في تسجيل الدخول: ${loginResult.message}'));
  //         return null;
  //       }
  //     } catch (e) {

  //       return null;
  //     }
  //   }
  //----------------------------------------------------------------------------
  void sendOtp() async {
    emit(AuthLoading());
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (FirebaseAuth.instance.currentUser != null) {
          emit(AuthSuccess(userInfo: _currentUserInfo!));
        } else {
          emit(AuthFailure(message: AuthString.autoVerificationFailed));
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        emit(AuthFailure(message: "فشل التحقق: ${e.message}"));
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

  //----------------------------------------------------------------------------
  void verifyOtp() async {
    if (_verificationId == null) {
      emit(AuthFailure(message: AuthString.noOTP));
      return;
    }
    if (_otp.isEmpty) {
      emit(AuthFailure(message: AuthString.otpVerificationFailed));
      return;
    }

    emit(AuthLoading());
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otp,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      if (userCredential.user != null) {
        final userRef = FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(userCredential.user!.uid);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final userDoc = await transaction.get(userRef);
          if (userDoc.exists) {
            _currentUserInfo = UserInfoData.fromJson(userDoc.data()!);
          } else {
            String? fcmToken = await messaging.getToken();
            final userInfo = UserInfoData(
              image: AuthString.empty,
              email: AuthString.empty,

              phoneNumber: number.phoneNumber ?? AuthString.empty,
              userId: _credential.currentUser!.uid,
              name: AuthString.empty,
              friends: _currentUserInfo?.friends ?? [],
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
            );
            await FirebaseFirestore.instance
                .collection(AuthString.fSUsers)
                .doc(_credential.currentUser!.uid)
                .set(userInfo.toJson());
            _currentUserInfo = userInfo;
          }
        });
        await _cacheService.saveUserData(_currentUserInfo!);
        emit(AuthSuccess(userInfo: _currentUserInfo!));
      } else {
        emit(AuthFailure(message: AuthString.noUser));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == AuthString.invalidVerificationCode) {
        emit(AuthFailure(message: AuthString.noCodeSent));
      } else {
        emit(AuthFailure(message: "فشل التحقق: ${e.message}"));
      }
    } catch (e) {
      emit(AuthFailure(message: "حدث خطأ غير متوقع: ${e.toString()}"));
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
}
