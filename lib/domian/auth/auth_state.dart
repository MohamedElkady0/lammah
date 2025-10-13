part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserInfoData userInfo;

  AuthSuccess({required this.userInfo});
}

class AuthSuccessSetUserInfo extends AuthState {
  final UserInfoData userInfo;

  AuthSuccessSetUserInfo({required this.userInfo});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
}

class ForGetPasswordSuccess extends AuthState {
  final String message;

  ForGetPasswordSuccess({required this.message});
}

class AuthImagePicked extends AuthState {
  final File image;
  AuthImagePicked(this.image);
}

class AuthLoadingProgress extends AuthState {
  final double progress;
  AuthLoadingProgress(this.progress);
}

class LocationUpdateSuccess extends AuthState {
  final LatLng position;
  LocationUpdateSuccess(this.position);
}

class ShowOnboardingState extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthCodeSentSuccess extends AuthState {}

class AuthUpdateSuccess extends AuthState {}
