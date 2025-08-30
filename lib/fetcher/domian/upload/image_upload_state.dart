import 'package:equatable/equatable.dart';

abstract class ImageUploadState extends Equatable {
  const ImageUploadState();

  @override
  List<Object> get props => [];
}

class ImageUploadInitial extends ImageUploadState {}

class ImageUploadLoading extends ImageUploadState {}

class ImageUploadSuccess extends ImageUploadState {
  final List<String> downloadUrls;

  const ImageUploadSuccess(this.downloadUrls);

  @override
  List<Object> get props => [downloadUrls];
}

class ImageUploadFailure extends ImageUploadState {
  final String error;

  const ImageUploadFailure(this.error);

  @override
  List<Object> get props => [error];
}
