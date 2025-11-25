// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String currentAddress = AuthString.noPlace;
  String? currentCountryCode;
  bool isLoading = true;
  final FirebaseAuth _credential = FirebaseAuth.instance;

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentAddress =
            '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
        currentPosition = LatLng(0, 0);

        await Geolocator.openLocationSettings();

        emit(
          LocationFailure(
            message: "يرجى تفعيل خدمة تحديد المواقع والمحاولة مرة أخرى.",
          ),
        );
        isLoading = false;
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentAddress =
              '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
          currentPosition = LatLng(0, 0);
          emit(LocationFailure(message: AuthString.noAddress));
          isLoading = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentAddress =
            '${AuthString.unknown},${AuthString.unknown},${AuthString.unknown}';
        currentPosition = LatLng(0, 0);
        emit(LocationFailure(message: AuthString.noAddressSelected));
        isLoading = false;

        // await Geolocator.openAppSettings();
        return;
      }

      isLoading = true;
      emit(LocationLoading());

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final newPosition = LatLng(position.latitude, position.longitude);
      currentPosition = newPosition;

      try {
        await getAddressFromLatLng(position);
      } catch (e) {
        print("Error getting address: $e");
      }

      if (_credential.currentUser != null) {
        currentUserInfo = currentUserInfo?.copyWith(
          userPlace:
              '${currentPosition?.latitude ?? 0.0}-${currentPosition?.longitude ?? 0.0}',
          userCity: currentAddress,
          userCountry: currentAddress.split(',')[0],
        );

        await FirebaseFirestore.instance
            .collection(AuthString.fSUsers)
            .doc(_credential.currentUser!.uid)
            .update({
              'latitude': newPosition.latitude,
              'longitude': newPosition.longitude,
              'userPlace': '${newPosition.latitude}-${newPosition.longitude}',
              'userCity': currentAddress,
              'userCountry': currentAddress.split(',')[0],
              'isOnline': true, // تحديث حالة الاتصال
            });
      }

      isLoading = false;
      emit(LocationUpdateSuccess(newPosition));
    } catch (e) {
      // debugPrint("Error in getCurrentLocation: $e");
      currentAddress =
          "خطأ في تحديد الموقع: ${e.toString()},${AuthString.unknown},${AuthString.unknown}";
      currentPosition = LatLng(0, 0);
      isLoading = false;
      emit(LocationFailure(message: "حدث خطأ أثناء محاولة تحديد موقعك."));
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
