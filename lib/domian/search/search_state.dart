import 'package:equatable/equatable.dart';
import 'package:lammah/data/model/user_info.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<UserInfoData> users;

  const SearchSuccess(this.users);

  @override
  List<Object> get props => [users];
}

class SearchFailure extends SearchState {
  final String message;

  const SearchFailure(this.message);

  @override
  List<Object> get props => [message];
}
