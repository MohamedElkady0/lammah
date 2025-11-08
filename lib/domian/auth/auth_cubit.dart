// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/user_info.dart';
import 'package:lammah/data/service/auth_cache_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_picker/country_picker.dart';

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
  LatLng? currentPosition;
  LatLng? countryPosition;
  String currentAddress = AuthString.noPlace;
  String? currentCountryCode;
  bool isLoading = true;
  SharedPreferences? prefs;

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

  Future<void> onIntroEnd() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AuthString.keyOfSeenOnboarding, true);

    final user = _credential.currentUser;
    if (user != null) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  //----------------------------------------------------------------------------
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
  //----------------------------------------------------------------------------

  Future<void> checkAppState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding =
        prefs.getBool(AuthString.keyOfSeenOnboarding) ?? false;

    if (!hasSeenOnboarding) {
      emit(ShowOnboardingState());
    } else {
      final user = _credential.currentUser;
      if (user != null) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }

  //------------------------------------------------------------------------------

  Future<void> loadUserData(String uid) async {
    final firebaseUser = _credential.currentUser;
    try {
      emit(AuthLoadingProgress(0.0));

      if (firebaseUser != null) {
        emit(AuthLoading());
        final docSnapshot = await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(uid)
            .get();
        emit(AuthLoadingProgress(0.5));
        await Future.delayed(const Duration(seconds: 1));

        if (docSnapshot.exists) {
          _currentUserInfo = UserInfoData.fromJson(docSnapshot.data()!);
          emit(AuthLoadingProgress(1.0)); // 100%
          await Future.delayed(const Duration(milliseconds: 300));
          if (_currentUserInfo != null) {
            emit(AuthSuccess(userInfo: _currentUserInfo!));
          } else {
            emit(AuthFailure(message: AuthString.userDoesNotExist));
            return;
          }
        }
      } else {
        emit(AuthFailure(message: AuthString.userDoesNotExist));
        return;
      }
    } catch (e) {
      if (e == AuthString.invalidGetUser) {
        emit(AuthFailure(message: AuthString.checkInternet));
      } else {
        emit(AuthFailure(message: e.toString()));
      }
    }
  }

  //----------------------------------------------------------------------------
  // if FirebaseAuth.instance.currentUser != null  && _currentUserInfo == null
  localUserInfo() async {
    try {
      emit(AuthLoading());

      emit(AuthLoadingProgress(0.5));
      await Future.delayed(const Duration(seconds: 1));
      _currentUserInfo = await _cacheService.loadUserData();
      emit(AuthLoadingProgress(1.0)); // 100%
      await Future.delayed(const Duration(milliseconds: 300));
      if (_currentUserInfo != null) {
        emit(AuthSuccess(userInfo: _currentUserInfo!));
      } else {
        emit(AuthFailure(message: AuthString.userDoesNotExist));
        return;
      }
    } catch (e) {
      if (e == AuthString.invalidGetUser) {
        emit(AuthFailure(message: AuthString.checkInternet));
      } else {
        emit(AuthFailure(message: e.toString()));
      }
    }
  }

  //----------------------------------------------------------------------------

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentAddress =
            '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
        currentPosition = LatLng(0, 0);

        await Geolocator.openLocationSettings();

        emit(
          AuthFailure(
            message: "يرجى تفعيل خدمة تحديد المواقع والمحاولة مرة أخرى.",
          ),
        );
        isLoading = false;
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentAddress =
              '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
          currentPosition = LatLng(0, 0);
          emit(AuthFailure(message: AuthString.noAddress));
          isLoading = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentAddress =
            '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
        currentPosition = LatLng(0, 0);
        emit(AuthFailure(message: AuthString.noAddressSelected));
        isLoading = false;

        // await Geolocator.openAppSettings();
        return;
      }

      isLoading = true;
      emit(AuthLoading());

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPosition = LatLng(position.latitude, position.longitude);
      currentPosition = newPosition;

      await getAddressFromLatLng(position);

      isLoading = false;
      emit(LocationUpdateSuccess(newPosition));
    } catch (e) {
      debugPrint("Error in getCurrentLocation: $e");
      currentAddress =
          "خطأ في تحديد الموقع: ${e.toString()},${AuthString.unknown},${AuthString.unknown}";
      currentPosition = LatLng(0, 0);
      isLoading = false;
      emit(AuthFailure(message: "حدث خطأ أثناء محاولة تحديد موقعك."));
    }
  }
  //----------------------------------------------------------------------------

  Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        currentAddress =
            '${place.country},${place.locality},${place.street},${place.locality},${place.postalCode}';

        if (place.country != null && place.country!.isNotEmpty) {
          try {
            Country country = Country.parse(place.country!);
            currentCountryCode = country.countryCode;
          } catch (e) {
            debugPrint(
              "Could not parse country name to get code: ${e.toString()}",
            );
            currentCountryCode = null;
          }
          try {
            List<Location> locations = await locationFromAddress(
              place.country!,
            );
            if (locations.isNotEmpty) {
              countryPosition = LatLng(
                locations.first.latitude,
                locations.first.longitude,
              );
            }
          } catch (e) {
            debugPrint("Could not geocode the country: ${e.toString()}");
            countryPosition = LatLng(position.latitude, position.longitude);
            currentCountryCode = null;
            currentAddress =
                '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());

      currentAddress =
          '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
      countryPosition = LatLng(0, 0);
    }
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
    if (currentPosition == null || currentAddress.isEmpty) {
      Future.delayed(Duration(seconds: 5));
      currentAddress = '${AuthString.noAddressSelected},unknown,unknown';
      currentPosition = LatLng(0, 0);
      emit(AuthFailure(message: AuthString.noLocation));
    }

    emit(AuthLoading());

    UserCredential? userCredential;

    try {
      userCredential = await _credential.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String imgUrl = await uploadImageAndGetUrl(img!);

      String? fcmToken = await messaging.getToken();
      final userInfo = UserInfoData(
        image: imgUrl,
        email: email,
        phoneNumber: number.phoneNumber ?? AuthString.empty,
        userId: _credential.currentUser!.uid,
        name: name,
        friends: [],
        userPlace: '${currentPosition?.latitude}-${currentPosition?.longitude}',
        userCity:
            '${currentAddress.split(',')[1]}-${currentAddress.split(',')[2]}',
        userCountry: currentAddress.split(',')[0],
        fcmToken: fcmToken,
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
      } else {
        emit(AuthFailure(message: AuthString.userDoesNotExist));
        return;
      }
      await _cacheService.saveUserData(_currentUserInfo!);

      emit(AuthSuccess(userInfo: _currentUserInfo!));
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

      if (currentPosition == null || currentAddress.isEmpty) {
        emit(AuthFailure(message: AuthString.noLocation));
        currentAddress = '${AuthString.noAddressSelected},unknown,unknown';
        currentPosition = LatLng(0, 0);
      }
      String? fcmToken = await messaging.getToken();
      UserInfoData userInfo = UserInfoData(
        userId: _credential.currentUser!.uid,
        name: userCredential.user!.displayName ?? AuthString.empty,
        email: userCredential.user!.email ?? AuthString.empty,
        phoneNumber: userCredential.user!.phoneNumber ?? AuthString.empty,
        image: userCredential.user!.photoURL ?? AuthString.empty,
        friends: _currentUserInfo?.friends ?? [],
        userPlace: '${currentPosition?.latitude}-${currentPosition?.longitude}',
        userCity:
            '${currentAddress.split(',')[1]}-${currentAddress.split(',')[2]}',
        userCountry: currentAddress.split(',')[0],
        fcmToken: fcmToken,
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
    if (currentPosition == null || currentAddress.isEmpty) {
      emit(AuthFailure(message: AuthString.noLocation));
      currentAddress = '${AuthString.noAddressSelected},unknown,unknown';
      currentPosition = LatLng(0, 0);
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
            if (currentPosition == null || currentAddress.isEmpty) {
              emit(AuthFailure(message: AuthString.noLocation));
              currentAddress = AuthString.noAddressSelected;
              currentPosition = LatLng(0, 0);
            }
            String? fcmToken = await messaging.getToken();
            final userInfo = UserInfoData(
              image: AuthString.empty,
              email: AuthString.empty,

              phoneNumber: number.phoneNumber ?? AuthString.empty,
              userId: _credential.currentUser!.uid,
              name: AuthString.empty,
              friends: _currentUserInfo?.friends ?? [],
              userPlace:
                  '${currentPosition?.latitude}-${currentPosition?.longitude}',
              userCity:
                  '${currentAddress.split(',')[1]}-${currentAddress.split(',')[2]}',
              userCountry: currentAddress.split(',')[0],
              fcmToken: fcmToken,
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

  //----------------------------------------------------------------------------
  void pickImage({required String title}) async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;
    if (title == AuthString.gallery) {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    }
    if (pickedFile == null) {
      return;
    }

    img = File(pickedFile.path);
    emit(AuthImagePicked(img!));
  }

  //----------------------------------------------------------------------------
  Future<String> uploadImageAndGetUrl(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(AuthString.fSUserImages)
          .child('${_credential.currentUser!.uid}.png');

      await storageRef.putFile(imageFile);
      final imgUrl = await storageRef.getDownloadURL();
      return imgUrl;
    } catch (e) {
      emit(AuthFailure(message: 'فشل رفع الصورة: ${e.toString()}'));
      throw Exception('فشل رفع الصورة: ${e.toString()}');
    }
  }

  //----------------------------------------------------------------------------
  void uploadAndUpdateProfileImage() async {
    if (img == null) {
      emit(AuthFailure(message: AuthString.choseImg));
      return;
    }

    emit(AuthLoading());

    try {
      final String imgUrl = await uploadImageAndGetUrl(img!);

      await _updateUserDocument(imgUrl);

      emit(AuthUpdateSuccess());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------------------
  Future<void> _updateUserDocument(String imageUrl) async {
    try {
      _currentUserInfo = _currentUserInfo?.copyWith(image: imageUrl);
      if (_currentUserInfo != null) {
        await _cacheService.saveUserData(_currentUserInfo!);
      }

      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .update({'image': imageUrl});
      emit(AuthUpdateSuccess());
    } catch (e) {
      Future.delayed(Duration(seconds: 5));
      throw Exception('فشل تحديث بيانات المستخدم: ${e.toString()}');
    }
  }

  //----------------------------------------------------------------------------
  void updateName(String name) async {
    _currentUserInfo = _currentUserInfo?.copyWith(name: name);
    if (_currentUserInfo != null) {
      await _cacheService.saveUserData(_currentUserInfo!);
      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .update(_currentUserInfo!.toJson());
    }
    emit(AuthUpdateSuccess());
  }

  //----------------------------------------------------------------------------
  void updatePhoneNumber(String phoneNumber) async {
    _currentUserInfo = _currentUserInfo?.copyWith(phoneNumber: phoneNumber);
    if (_currentUserInfo != null) {
      await _cacheService.saveUserData(_currentUserInfo!);
      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .update(_currentUserInfo!.toJson());
    }
    emit(AuthUpdateSuccess());
  }

  //----------------------------------------------------------------------------

  void updateEmail(String email) async {
    _currentUserInfo = _currentUserInfo?.copyWith(email: email);
    if (_currentUserInfo != null) {
      await _cacheService.saveUserData(_currentUserInfo!);
      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .update(_currentUserInfo!.toJson());
    }
    emit(AuthUpdateSuccess());
  }

  //----------------------------------------------------------------------------
  void updateLocation() async {
    getCurrentLocation();
    _currentUserInfo = _currentUserInfo?.copyWith(
      userPlace: '${currentPosition?.latitude}-${currentPosition?.longitude}',
      userCity: currentAddress,
      userCountry: currentAddress.split(',')[0],
    );
    if (_currentUserInfo != null) {
      await _cacheService.saveUserData(_currentUserInfo!);
      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .update(_currentUserInfo!.toJson());
    }
    emit(AuthUpdateSuccess());
  }

  //----------------------------------------------------------------------------
}
