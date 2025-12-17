import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/user_info.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
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
  // أضف معامل AuthCubit للدالة لكي نتمكن من تحديثه
  void updateLocation(AuthCubit authCubit) async {
    emit(UpdateLoading());
    try {
      await locationCubit.getCurrentLocation();

      if (locationCubit.state is LocationFailure) {
        emit(UpdateFailure(message: "فشل تحديد الموقع"));
        return;
      }

      final pos = locationCubit.currentPosition;
      // نستخدم العنوان الجديد الذي جلبه LocationCubit
      final address = locationCubit.currentAddress;

      // التأكد أن العنوان ليس فارغاً أو غير معروف
      final city = (address != null && address.contains(','))
          ? address.split(',')[0]
          : address ?? 'غير معروف';

      if (pos != null) {
        // 1. تحديث Firestore
        final updatedData = {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'userPlace': '${pos.latitude}-${pos.longitude}',
          'userCity': address,
          'userCountry': city, // تخزين اسم الدولة/المدينة
        };

        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(_credential.currentUser!.uid)
            .update(updatedData);

        // 2. تحديث AuthCubit لكي تتغير الواجهة فوراً (مهم جداً)
        // نقوم بتحديث الكائن الموجود في الذاكرة
        if (authCubit.currentUserInfo != null) {
          final updatedUser = authCubit.currentUserInfo!.copyWith(
            latitude: pos.latitude,
            longitude: pos.longitude,
            userPlace: '${pos.latitude}-${pos.longitude}',
            userCity: address,
            userCountry: city,
          );

          // نفترض أن لديك دالة في AuthCubit لتحديث المستخدم محلياً updateLocalUser
          // أو يمكنك عمل emit لحالة جديدة إذا كان مسموحاً
          authCubit.updateLocalUser(updatedUser);
          emit(UpdateSuccess(updatedUserInfo: updatedUser));
        }
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
