import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/fetcher/data/model/user_info.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  //----------------variables---------------------------------------------------
  UserInfoData? _currentUserInfo;
  UserInfoData? get currentUserInfo => _currentUserInfo;
  set currentUserInfo(UserInfoData? userInfo) {
    emit(AuthSuccess(userInfo: userInfo!));
  }

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
  String currentAddress = AuthString.noPlace;
  MapController? mapController;
  bool isLoading = true;
  SharedPreferences? prefs;
  // ---------------------------------------------------------------------------

  final FirebaseAuth _credential = FirebaseAuth.instance;
  StreamSubscription? _authSubscription;
  //----------------------------------------------------------------------------
  AuthCubit() : super(AuthInitial()) {
    _monitorAuthenticationState();
  }

  void _monitorAuthenticationState() {
    _authSubscription?.cancel();

    _authSubscription = _credential.authStateChanges().listen((
      User? user,
    ) async {
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenOnboarding =
          prefs.getBool(AuthString.keyOfSeenOnboarding) ?? false;

      if (!hasSeenOnboarding) {
        emit(ShowOnboardingState());
      } else {
        if (user != null) {
          emit(AuthLoading());
          try {
            emit(AuthSuccess(userInfo: _currentUserInfo!));
          } catch (e) {
            emit(
              AuthFailure(
                message: 'خطأ في تحميل بيانات المستخدم: ${e.toString()}',
              ),
            );
          }
          emit(AuthAuthenticated());
        } else {
          emit(AuthUnauthenticated());
        }
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
  //----------------------------------------------------------------------------

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      currentAddress = AuthString.noLocation;
      isLoading = false;

      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        currentAddress = AuthString.noAddress;
        isLoading = false;

        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      currentAddress = AuthString.noAddressSelected;
      isLoading = false;

      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPosition = LatLng(position.latitude, position.longitude);

      currentPosition = newPosition;
      isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentPosition != null) {
          mapController?.move(currentPosition!, 2.0);
        }
      });

      getAddressFromLatLng(position);
    } catch (e) {
      debugPrint("Error getting location: $e");
      // if (!mounted) return;

      currentAddress = "خطأ في تحديد الموقع: ${e.toString()}";
      isLoading = false;
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

        currentAddress = '${place.country},${place.street},${place.locality}';
      }
    } catch (e) {
      debugPrint(e.toString());

      currentAddress = AuthString.noAddressSelected2;
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

    emit(AuthLoading());

    UserCredential? userCredential;

    try {
      userCredential = await _credential.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String imgUrl = await _uploadImageAndGetUrl(img!);

      final userInfo = UserInfoData(
        image: imgUrl,
        email: email,
        phoneNumber: number.phoneNumber ?? AuthString.empty,
        userId: userCredential.user!.uid,
        name: name,
        friends: [],
        userPlace: '${currentPosition?.latitude}-${currentPosition?.longitude}',
        userCity:
            '${currentAddress.split(',')[1]}-${currentAddress.split(',')[2]}',
        userCountry: currentAddress.split(',')[0],
      );

      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(userCredential.user!.uid)
          .set(userInfo.toJson());

      _currentUserInfo = userInfo;
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
        emit(
          state is AuthInitial
              ? AuthFailure(message: AuthString.userDoesNotExist)
              : AuthFailure(message: AuthString.userDoesNotExist),
        );
        return;
      }

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

      UserInfoData userInfo = UserInfoData(
        userId: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? AuthString.empty,
        email: userCredential.user!.email ?? AuthString.empty,
        phoneNumber: userCredential.user!.phoneNumber ?? AuthString.empty,
        image: userCredential.user!.photoURL ?? AuthString.empty,
        friends: _currentUserInfo?.friends ?? [],
        userPlace: '${currentPosition?.latitude}-${currentPosition?.longitude}',
        userCity:
            '${currentAddress.split(',')[1]}-${currentAddress.split(',')[2]}',
        userCountry: currentAddress.split(',')[0],
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
      _currentUserInfo = userInfo;
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
            final userInfo = UserInfoData(
              image: AuthString.empty,
              email: AuthString.empty,
              password: AuthString.empty,

              phoneNumber: number.phoneNumber ?? AuthString.empty,
              userId: userCredential.user!.uid,
              name: AuthString.empty,
              friends: _currentUserInfo?.friends ?? [],
              userPlace:
                  '${currentPosition?.latitude}-${currentPosition?.longitude}',
              userCity:
                  '${currentAddress.split(',')[1]}-${currentAddress.split(',')[2]}',
              userCountry: currentAddress.split(',')[0],
            );
            await FirebaseFirestore.instance
                .collection(AuthString.fSUsers)
                .doc(userCredential.user!.uid)
                .set(userInfo.toJson());
            _currentUserInfo = userInfo;
          }
        });
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
  Future<String> _uploadImageAndGetUrl(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(AuthString.fSUserImages)
          .child('${_credential.currentUser!.uid}.png');

      await storageRef.putFile(imageFile);
      final imgUrl = await storageRef.getDownloadURL();
      return imgUrl;
    } catch (e) {
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
      final String imgUrl = await _uploadImageAndGetUrl(img!);

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

      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .update({'image': imageUrl});
    } catch (e) {
      throw Exception('فشل تحديث بيانات المستخدم: ${e.toString()}');
    }
  }

  //----------------------------------------------------------------------------
  void updateName(String name) async {
    _currentUserInfo = _currentUserInfo?.copyWith(name: name);
    await FirebaseFirestore.instance
        .collection(AuthString.fSUsers)
        .doc(_credential.currentUser!.uid)
        .update(_currentUserInfo!.toJson());
  }

  //----------------------------------------------------------------------------
  void updatePhoneNumber(String phoneNumber) async {
    _currentUserInfo = _currentUserInfo?.copyWith(phoneNumber: phoneNumber);
    await FirebaseFirestore.instance
        .collection(AuthString.fSUsers)
        .doc(_credential.currentUser!.uid)
        .update(_currentUserInfo!.toJson());
  }

  //----------------------------------------------------------------------------
  void updatePassword(String password) async {
    _currentUserInfo = _currentUserInfo?.copyWith(password: password);
    await FirebaseFirestore.instance
        .collection(AuthString.fSUsers)
        .doc(_credential.currentUser!.uid)
        .update(_currentUserInfo!.toJson());
  }

  //----------------------------------------------------------------------------
  void updateEmail(String email) async {
    _currentUserInfo = _currentUserInfo?.copyWith(email: email);
    await FirebaseFirestore.instance
        .collection(AuthString.fSUsers)
        .doc(_credential.currentUser!.uid)
        .update(_currentUserInfo!.toJson());
  }

  //----------------------------------------------------------------------------
  void updateLocation() async {
    getCurrentLocation();
    _currentUserInfo = _currentUserInfo?.copyWith(
      userPlace: '${currentPosition?.latitude}-${currentPosition?.longitude}',
      userCity:
          '${currentAddress.split(',')[1]}-${currentAddress.split(',')[2]}',
      userCountry: currentAddress.split(',')[0],
    );
    await FirebaseFirestore.instance
        .collection(AuthString.fSUsers)
        .doc(_credential.currentUser!.uid)
        .update(_currentUserInfo!.toJson());
  }

  //----------------------------------------------------------------------------
}
