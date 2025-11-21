part of 'location_cubit.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}

class LocationUpdateSuccess extends LocationState {
  final LatLng position;
  const LocationUpdateSuccess(this.position);
}

class LocationFailure extends LocationState {
  final String message;
  const LocationFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class LocationLoading extends LocationState {}
