part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserInfoData userInfo;

  AuthSuccess({required this.userInfo});
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

class ShowOnboardingState extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthCodeSentSuccess extends AuthState {}

class AuthUpdateSuccess extends AuthState {}
