import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/user_info.dart';
import 'package:lammah/domian/location/location_cubit.dart';

part 'updateuser_state.dart';

class UpdateUserCubit extends Cubit<UpdateUserState> {
  final LocationCubit locationCubit;

  // الحقن في المنشئ
  UpdateUserCubit({required this.locationCubit}) : super(UpdateUserInitial());

  UserInfoData? currentUserInfo;
  final FirebaseAuth _credential = FirebaseAuth.instance;

  void updateName(String name) async {
    emit(UpdateLoading());
    try {
      currentUserInfo = currentUserInfo?.copyWith(name: name);
      if (currentUserInfo != null) {
        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(_credential.currentUser!.uid)
            .update(currentUserInfo!.toJson());
      }
      emit(UpdateSuccess());
    } on Exception catch (e) {
      emit(UpdateFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------------------
  void updatePhoneNumber(String phoneNumber) async {
    emit(UpdateLoading());
    try {
      currentUserInfo = currentUserInfo?.copyWith(phoneNumber: phoneNumber);
      if (currentUserInfo != null) {
        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(_credential.currentUser!.uid)
            .update(currentUserInfo!.toJson());
      }
      emit(UpdateSuccess());
    } on Exception catch (e) {
      emit(UpdateFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------------------

  void updateEmail(String email) async {
    emit(UpdateLoading());
    try {
      currentUserInfo = currentUserInfo?.copyWith(email: email);
      if (currentUserInfo != null) {
        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(_credential.currentUser!.uid)
            .update(currentUserInfo!.toJson());
      }
      emit(UpdateSuccess());
    } on Exception catch (e) {
      emit(UpdateFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------------------
  void updateLocation() async {
    emit(UpdateLoading());
    try {
      // ننتظر حتى ينتهي الـ LocationCubit من جلب الموقع
      await locationCubit.getCurrentLocation();

      // نتحقق من الحالة الحالية للـ LocationCubit
      if (locationCubit.state is LocationFailure) {
        emit(UpdateFailure(message: "فشل تحديد الموقع"));
        return;
      }

      // نستخدم البيانات المخزنة داخل LocationCubit
      final pos = locationCubit.currentPosition;
      final address = locationCubit.currentAddress;

      if (pos != null) {
        currentUserInfo = currentUserInfo?.copyWith(
          userPlace: '${pos.latitude}-${pos.longitude}',
          userCity: address,
          userCountry: address.split(',')[0],
        );

        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(_credential.currentUser!.uid)
            .update(currentUserInfo!.toJson());

        emit(UpdateSuccess());
      }
    } catch (e) {
      emit(UpdateFailure(message: e.toString()));
    }
  }

  //----------------------------------------------------------------------------
  Future<void> updateUserDocument(String imageUrl) async {
    try {
      currentUserInfo = currentUserInfo?.copyWith(image: imageUrl);

      await FirebaseFirestore.instance
          .collection(AuthString.fSUsers)
          .doc(_credential.currentUser!.uid)
          .update({'image': imageUrl});
      emit(UpdateSuccess());
    } catch (e) {
      emit(
        UpdateFailure(message: 'فشل تحديث بيانات المستخدم: ${e.toString()}'),
      );
    }
  }
}
