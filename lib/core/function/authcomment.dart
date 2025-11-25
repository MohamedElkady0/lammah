  // //----------------------------------------------------------------------------

  // Future<void> onIntroEnd() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(AuthString.keyOfSeenOnboarding, true);

  //   final user = _credential.currentUser;
  //   if (user != null) {
  //     emit(AuthAuthenticated());
  //   } else {
  //     emit(AuthUnauthenticated());
  //   }
  // }

  // //----------------------------------------------------------------------------

  // Future<void> checkAppState() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final bool hasSeenOnboarding =
  //       prefs.getBool(AuthString.keyOfSeenOnboarding) ?? false;

  //   if (!hasSeenOnboarding) {
  //     emit(ShowOnboardingState());
  //   } else {
  //     final user = _credential.currentUser;
  //     if (user != null) {
  //       emit(AuthAuthenticated());
  //     } else {
  //       emit(AuthUnauthenticated());
  //     }
  //   }
  // }


  // //------------------------------------------------------------------------------

  // Future<void> loadUserData(String uid) async {
  //   final firebaseUser = _credential.currentUser;
  //   try {
  //     emit(AuthLoadingProgress(0.0));

  //     if (firebaseUser != null) {
  //       emit(AuthLoading());
  //       final docSnapshot = await FirebaseFirestore.instance
  //           .collection(AuthString.fSUsers)
  //           .doc(uid)
  //           .get();
  //       emit(AuthLoadingProgress(0.5));
  //       await Future.delayed(const Duration(seconds: 1));

  //       if (docSnapshot.exists) {
  //         _currentUserInfo = UserInfoData.fromJson(docSnapshot.data()!);
  //         emit(AuthLoadingProgress(1.0)); // 100%
  //         await Future.delayed(const Duration(milliseconds: 300));
  //         if (_currentUserInfo != null) {
  //           emit(AuthSuccess(userInfo: _currentUserInfo!));
  //         } else {
  //           emit(AuthFailure(message: AuthString.userDoesNotExist));
  //           return;
  //         }
  //       }
  //     } else {
  //       emit(AuthFailure(message: AuthString.userDoesNotExist));
  //       return;
  //     }
  //   } catch (e) {
  //     if (e == AuthString.invalidGetUser) {
  //       emit(AuthFailure(message: AuthString.checkInternet));
  //     } else {
  //       emit(AuthFailure(message: e.toString()));
  //     }
  //   }
  // }

  // //----------------------------------------------------------------------------
  // // if FirebaseAuth.instance.currentUser != null  && _currentUserInfo == null
  // localUserInfo() async {
  //   try {
  //     emit(AuthLoading());

  //     emit(AuthLoadingProgress(0.5));
  //     await Future.delayed(const Duration(seconds: 1));
  //     _currentUserInfo = await _cacheService.loadUserData();
  //     emit(AuthLoadingProgress(1.0)); // 100%
  //     await Future.delayed(const Duration(milliseconds: 300));
  //     if (_currentUserInfo != null) {
  //       emit(AuthSuccess(userInfo: _currentUserInfo!));
  //     } else {
  //       emit(AuthFailure(message: AuthString.userDoesNotExist));
  //       return;
  //     }
  //   } catch (e) {
  //     if (e == AuthString.invalidGetUser) {
  //       emit(AuthFailure(message: AuthString.checkInternet));
  //     } else {
  //       emit(AuthFailure(message: e.toString()));
  //     }
  //   }
  // }



//  Future<void> getCurrentLocation() async {
//     emit(LocationLoading());
//     try {
//       // 1. Check Service
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         await Geolocator.openLocationSettings();
//         emit(LocationFailure(message: "يرجى تفعيل الموقع"));
//         return;
//       }

//       // 2. Check Permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           emit(LocationFailure(message: "تم رفض إذن الموقع"));
//           return;
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         emit(LocationFailure(message: "إذن الموقع مرفوض نهائياً"));
//         return;
//       }

//       // 3. Get Position
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.medium,
//       );
      
//       currentPosition = LatLng(position.latitude, position.longitude);
//       await getAddressFromLatLng(position);

//       emit(LocationUpdateSuccess(currentPosition!));
//     } catch (e) {
//       emit(LocationFailure(message: e.toString()));
//     }
//   }


// // داخل CartCubit
// void checkout() {
//   // هنا لا نستمع، بل نسأل: "ما هي الحالة الآن؟"
//   final currentState = locationCubit.state; 

//   if (currentState is LocationLoaded) {
//     // الموقع موجود، أكمل عملية الدفع
//     processPayment(address: currentState.address);
//   } else {
//     // الموقع غير موجود، اطلب من المستخدم تحديد موقعه
//     emit(CartError(message: "يرجى تحديد الموقع أولاً"));
//   }
// }

// داخل CartCubit
// locationSubscription = locationCubit.stream.listen((locationState) {
//   // هذا الكود سيعمل "في كل مرة" يتغير فيها الـ Location
//   if (locationState is LocationLoaded) {
//      calculateDeliveryFee(locationState.address); 
//   }
// });

    // // 2. تعريف الـ Cubit الثاني وحقن الأول داخله
    // BlocProvider<CartCubit>(
    //   create: (context) => CartCubit(
    //     // هنا نحصل على النسخة المنشأة أعلاه ونمررها
    //     locationCubit: BlocProvider.of<LocationCubit>(context),
    //   ),
    // ),


  //     @override
  // Future<void> close() {
  //   // ضروري جداً إلغاء الاشتراك لتجنب Memory Leaks
  //   locationSubscription.cancel();
  //   return super.close();
  // }

  // class CartCubit extends Cubit<CartState> {
  // final LocationCubit locationCubit;
  // late StreamSubscription locationSubscription;

  // // نمرر الـ LocationCubit هنا في الـ Constructor
  // CartCubit({required this.locationCubit}) : super(CartInitial()) {
    
  //   // الاستماع للتغييرات في الـ LocationCubit
  //   locationSubscription = locationCubit.stream.listen((locationState) {
  //     if (locationState is LocationLoaded) {
  //       // قم بعمل منطق معين عند تغير الموقع
  //       calculateDeliveryFee(locationState.address);
  //     }
  //   });



                // // إنشاء مستند جديد للعبة
                // final gameSession = await FirebaseFirestore.instance
                //     .collection('games')
                //     .add({
                //       'players': [currentUser.userId, otherUserUid],
                //       'board': List.generate(9, (_) => ""), // لوحة فارغة
                //       'currentPlayerUid': currentUser.userId, // أنت تبدأ
                //       'winner': "",
                //       'status': "playing",
                //     });