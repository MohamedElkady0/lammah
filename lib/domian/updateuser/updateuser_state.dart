part of 'updateuser_cubit.dart';

abstract class UpdateUserState extends Equatable {
  const UpdateUserState();

  @override
  List<Object> get props => [];
}

class UpdateUserInitial extends UpdateUserState {}

class UpdateSuccess extends UpdateUserState {
  final UserInfoData? updatedUserInfo;
  const UpdateSuccess({this.updatedUserInfo});
}

class UpdateFailure extends UpdateUserState {
  final String message;
  const UpdateFailure({required this.message});
}

class UpdateLoading extends UpdateUserState {}
