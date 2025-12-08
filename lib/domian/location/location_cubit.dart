// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lammah/core/utils/auth_string.dart';
import 'package:lammah/data/model/user_info.dart';
import 'package:latlong2/latlong.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  UserInfoData? currentUserInfo;

  LatLng? currentPosition;
  LatLng? countryPosition;
  String? currentAddress;
  String? currentCountryCode;
  bool isLoading = true;
  final FirebaseAuth _credential = FirebaseAuth.instance;

  // Future<void> getCurrentLocation() async {
  //   try {
  //     bool serviceEnabled;
  //     LocationPermission permission;

  //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       currentAddress =
  //           '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
  //       currentPosition = LatLng(0, 0);

  //       await Geolocator.openLocationSettings();

  //       emit(
  //         LocationFailure(
  //           message: "يرجى تفعيل خدمة تحديد المواقع والمحاولة مرة أخرى.",
  //         ),
  //       );
  //       isLoading = false;
  //       return;
  //     }

  //     permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         currentAddress =
  //             '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
  //         currentPosition = LatLng(0, 0);
  //         emit(LocationFailure(message: AuthString.noAddress));
  //         isLoading = false;
  //         return;
  //       }
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       currentAddress =
  //           '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
  //       currentPosition = LatLng(0, 0);
  //       emit(LocationFailure(message: AuthString.noAddressSelected));
  //       isLoading = false;

  //       // await Geolocator.openAppSettings();
  //       return;
  //     }

  //     isLoading = true;
  //     emit(LocationLoading());

  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.medium,
  //     );

  //     final newPosition = LatLng(position.latitude, position.longitude);
  //     currentPosition = newPosition;

  //     try {
  //       await getAddressFromLatLng(position);
  //     } catch (e) {
  //       print("Error getting address: $e");
  //     }

  //     if (_credential.currentUser != null) {
  //       currentUserInfo = currentUserInfo?.copyWith(
  //         userPlace:
  //             '${currentPosition?.latitude ?? 0.0}-${currentPosition?.longitude ?? 0.0}',
  //         userCity: currentAddress,
  //         userCountry: currentAddress.split(',')[0],
  //       );

  //       await FirebaseFirestore.instance
  //           .collection(AuthString.fSUsers)
  //           .doc(_credential.currentUser!.uid)
  //           .update({
  //             'latitude': newPosition.latitude,
  //             'longitude': newPosition.longitude,
  //             'userPlace': '${newPosition.latitude}-${newPosition.longitude}',
  //             'userCity': currentAddress,
  //             'userCountry': currentAddress.split(',')[0],
  //             'isOnline': true, // تحديث حالة الاتصال
  //           });
  //     }

  //     isLoading = false;
  //     emit(LocationUpdateSuccess(newPosition));
  //   } catch (e) {
  //     // debugPrint("Error in getCurrentLocation: $e");
  //     currentAddress =
  //         "خطأ في تحديد الموقع: ${e.toString()},${AuthString.unknown},${AuthString.unknown}";
  //     currentPosition = LatLng(0, 0);
  //     isLoading = false;
  //     emit(LocationFailure(message: "حدث خطأ أثناء محاولة تحديد موقعك."));
  //   }
  // }

  Future<void> getCurrentLocation() async {
    try {
      emit(LocationLoading());

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        emit(LocationFailure(message: "خدمة الموقع غير مفعلة"));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(LocationFailure(message: AuthString.noAddress));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(LocationFailure(message: AuthString.noAddressSelected));
        return;
      }

      // === التغيير الجوهري هنا ===

      Position? position;

      // 1. محاولة الحصول على آخر موقع معروف (سريع جداً)
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (e) {
        // تجاهل الخطأ واكمل
      }

      // 2. إذا لم نجد موقعاً سابقاً، نحاول جلب الموقع الحالي مع مهلة زمنية (5 ثواني)
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            // هذا يمنع التعليق اللانهائي
            timeLimit: const Duration(seconds: 5),
          );
        } catch (e) {
          // إذا فشل أو انتهى الوقت، نستخدم موقع افتراضي (القاهرة مثلاً) لكي لا يتوقف التطبيق
          // هذا حل مؤقت للمحاكي فقط
          debugPrint("فشل تحديد الموقع، استخدام موقع افتراضي: $e");
          position = Position(
            longitude: 31.2357,
            latitude: 30.0444,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }

      currentPosition = LatLng(position.latitude, position.longitude);

      // محاولة جلب العنوان (Geocoding)
      try {
        await getAddressFromLatLng(position);
      } catch (e) {
        debugPrint("خطأ في جلب العنوان: $e");
        currentAddress = "موقع غير معروف";
      }

      // تحديث البيانات في Firestore
      if (_credential.currentUser != null) {
        // تأكد من أن currentUserInfo محدث قبل الإرسال
        // إذا كان null، نستخدم البيانات الأساسية فقط
        final Map<String, dynamic> dataToUpdate = {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'userPlace': '${position.latitude}-${position.longitude}',
          'userCity': currentAddress,
          'userCountry': currentAddress?.split(',')[0] ?? 'موقع غير معروف',
        };

        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(_credential.currentUser!.uid)
            .update(dataToUpdate);
      }

      currentUserInfo = currentUserInfo?.copyWith(
        userPlace:
            '${currentPosition?.latitude ?? 0.0}-${currentPosition?.longitude ?? 0.0}',
        userCity: currentAddress,
        userCountry: currentAddress?.split(',')[0] ?? 'موقع غير معروف',
        latitude: currentPosition?.latitude ?? 0.0,
        longitude: currentPosition?.longitude ?? 0.0,
      );

      isLoading = false;
      emit(LocationUpdateSuccess(currentPosition!));
    } catch (e) {
      debugPrint("Error in getCurrentLocation: $e");
      isLoading = false;
      emit(LocationFailure(message: "حدث خطأ غير متوقع: $e"));
    }
  }
  //----------------------------------------------------------------------------

  Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // تعديل: استخدام administrativeArea بدلاً من تكرار locality
        // وتأكدنا أننا خزننا العنوان أولاً قبل الدخول في العمليات الخطرة التالية
        currentAddress =
            '${place.country},${place.locality},${place.street},${place.administrativeArea},${place.postalCode}';

        // العمليات الإضافية (جلب كود الدولة وموقعها)
        if (place.country != null && place.country!.isNotEmpty) {
          // محاولة جلب كود الدولة
          try {
            Country country = Country.parse(place.country!);
            currentCountryCode = country.countryCode;
          } catch (e) {
            currentCountryCode = null;
          }

          // محاولة جلب إحداثيات الدولة
          try {
            List<Location> locations = await locationFromAddress(
              place.country!,
            );
            if (locations.isNotEmpty) {
              countryPosition = LatLng(
                locations.first.latitude,
                locations.first.longitude,
              );
            }
          } catch (e) {
            // debugPrint("Could not geocode the country: ${e.toString()}");
            // في حالة الفشل هنا، نستخدم موقع المستخدم الحالي كبديل لموقع الدولة
            countryPosition = LatLng(position.latitude, position.longitude);

            // هام: قمنا بإزالة السطر الذي كان يمسح currentAddress ويجعله unknown
            // لأننا بالفعل نمتلك العنوان الصحيح من الخطوة الأولى
          }
        }
      }
    } catch (e) {
      // debugPrint(e.toString());
      // هنا فقط (إذا فشل كل شيء) نضع القيم المجهولة
      currentAddress =
          '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
      countryPosition = LatLng(0, 0);
    }
  }
}
