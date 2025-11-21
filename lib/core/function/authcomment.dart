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


