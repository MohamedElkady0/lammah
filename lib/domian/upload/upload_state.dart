import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object> get props => [];
}

class UploadInitial extends UploadState {}

class UploadLoading extends UploadState {}

class UploadSuccess extends UploadState {
  final List<String> downloadUrls;

  const UploadSuccess(this.downloadUrls);

  @override
  List<Object> get props => [downloadUrls];
}

class UploadFailure extends UploadState {
  final String error;

  const UploadFailure(this.error);

  @override
  List<Object> get props => [error];
}

class RecordingStateChanged extends UploadState {
  final bool isRecording;
  const RecordingStateChanged(this.isRecording);
}

class ImagePicked extends UploadState {
  final File image;
  const ImagePicked(this.image);
}

class UploadSuccessImage extends UploadState {
  final String imageUrl;
  const UploadSuccessImage(this.imageUrl);
}
