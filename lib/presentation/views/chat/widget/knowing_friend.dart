import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lammah/presentation/views/chat/views/chat/chat_send_res.dart';
import 'package:latlong2/latlong.dart';
import 'package:lammah/core/utils/chat_string.dart';
import 'package:lammah/core/utils/string_app.dart';
import 'package:lammah/domian/auth/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:circle_flags/circle_flags.dart';
import 'package:country_flags/country_flags.dart';

// نموذج بسيط لبيانات المستخدم الذي تم اختياره
class MatchedUser {
  final String uid;
  final String name;
  final String image;
  final String country;
  final LatLng position;

  MatchedUser({
    required this.uid,
    required this.name,
    required this.image,
    required this.country,
    required this.position,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController mapController = MapController();

  // متغيرات للرحلة
  MatchedUser? _matchedUser;
  bool _isFindingTrip = false;

  // للتحريك
  late AnimationController _animationController;
  Animation<double>? animation;
  Tween<double>? _latTween;
  Tween<double>? _lngTween;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getCurrentLocation();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // مدة الرحلة
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_matchedUser != null) {
          _showConfirmationDialog(_matchedUser!);
        }
      }
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _findNewTrip() async {
    setState(() {
      _isFindingTrip = true;
      _matchedUser = null;
      _animationController.reset();
    });

    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.currentUserInfo;
    if (currentUser == null) {
      setState(() {
        _isFindingTrip = false;
      });
      return;
    }

    // --- منطق اختيار مستخدم عشوائي ---
    final randomId = FirebaseFirestore.instance.collection('users').doc().id;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isOnline', isEqualTo: true) // ابحث فقط في المستخدمين الأونلاين
        .where(FieldPath.documentId, isNotEqualTo: currentUser.userId)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: randomId)
        .limit(1)
        .get();

    DocumentSnapshot? userDoc;
    if (querySnapshot.docs.isNotEmpty) {
      userDoc = querySnapshot.docs.first;
    } else {
      // إذا لم نجد أحداً، حاول البحث مرة أخرى من بداية القائمة
      final fallbackQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .where(FieldPath.documentId, isNotEqualTo: currentUser.userId)
          .limit(1)
          .get();
      if (fallbackQuery.docs.isNotEmpty) {
        userDoc = fallbackQuery.docs.first;
      }
    }

    if (userDoc != null) {
      final userData = userDoc.data() as Map<String, dynamic>;
      // تأكد من أن المستخدم لديه بيانات الموقع
      if (userData['latitude'] != null && userData['longitude'] != null) {
        final position = LatLng(userData['latitude'], userData['longitude']);

        final matchedUser = MatchedUser(
          uid: userDoc.id,
          name: userData['name'] ?? 'مستخدم',
          image: userData['image'] ?? '',
          country: userData['userCountry'] ?? 'غير معروف',
          position: position,
        );
        _startFlightAnimation(
          authCubit.currentPosition!,
          position,
          matchedUser,
        );
      } else {
        // إذا لم يكن لديه بيانات موقع، ابحث مرة أخرى
        _findNewTrip();
      }
    } else {
      setState(() {
        _isFindingTrip = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على مستخدمين متاحين حالياً.'),
          ),
        );
      }
    }
  }

  void _startFlightAnimation(LatLng start, LatLng end, MatchedUser user) {
    _latTween = Tween<double>(begin: start.latitude, end: end.latitude);
    _lngTween = Tween<double>(begin: start.longitude, end: end.longitude);

    animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.reset();
    _animationController.forward();

    setState(() {
      _matchedUser = user;
      _isFindingTrip = false;
      // تحريك الخريطة لرؤية نقطتي البداية والنهاية
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(start, end),
          padding: const EdgeInsets.all(50.0),
        ),
      );
    });
  }

  void _showConfirmationDialog(MatchedUser user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final authCubit = context.read<AuthCubit>();
        final isFriend =
            authCubit.currentUserInfo!.friends?.contains(user.uid) ?? false;

        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          title: Center(
            child: Text(
              'تم العثور على رحلة!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user.image.isNotEmpty
                    ? NetworkImage(user.image)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(user.country),
              if (!isFriend)
                TextButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('إضافة كصديق'),
                  onPressed: () {
                    // منطق إرسال طلب الصداقة
                  },
                ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: const Text('رحلة أخرى'),
              onPressed: () {
                Navigator.of(ctx).pop();
                _findNewTrip();
              },
            ),
            ElevatedButton(
              child: const Text('تأكيد وبدء المحادثة'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SendResChat(
                      userName: user.name,
                      userImage: user.image,
                      uid: user.uid,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final authCubit = context.read<AuthCubit>();
        final positionForMap = authCubit.currentPosition;
        final userInfoData = authCubit.currentUserInfo;

        if (positionForMap == null || userInfoData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: positionForMap,
                initialZoom: 2.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: ChatString.mapImg,
                  userAgentPackageName: StringApp.packageName,
                ),
                MarkerLayer(
                  markers: [
                    // --- ماركر المستخدم الحالي ---
                    Marker(
                      width: 60.0,
                      height: 60.0,
                      point: positionForMap,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (authCubit.currentCountryCode != null)
                            CircleFlag(authCubit.currentCountryCode!, size: 60),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: userInfoData.image != null
                                  ? NetworkImage(userInfoData.image!)
                                  : MemoryImage(kTransparentImage)
                                        as ImageProvider,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // --- ماركر المستخدم الذي تم اختياره ---
                    // --- ماركر المستخدم الذي تم اختياره ---
                    if (_matchedUser != null &&
                        !_animationController.isAnimating)
                      Marker(
                        width: 60.0,
                        height: 60.0,
                        point: _matchedUser!.position,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // استخدام رمز 'UN' (Unknown) كاحتياطي إذا كانت الدولة غير معروفة
                            CircleFlag(_matchedUser?.country ?? 'UN', size: 60),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.grey.shade300,
                                // استخدام null-aware operators للتعامل مع الصور الفارغة
                                backgroundImage:
                                    _matchedUser?.image != null &&
                                        _matchedUser!.image.isNotEmpty
                                    ? NetworkImage(_matchedUser!.image)
                                    : MemoryImage(kTransparentImage)
                                          as ImageProvider,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                // --- طبقة الطائرة المتحركة ---
                if (_animationController.isAnimating &&
                    _latTween != null &&
                    _lngTween != null)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final lat = _latTween!.transform(
                        _animationController.value,
                      );
                      final lng = _lngTween!.transform(
                        _animationController.value,
                      );
                      final rotation = getRotation(
                        LatLng(_latTween!.begin!, _lngTween!.begin!),
                        LatLng(lat, lng),
                      );

                      return MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 50,
                            height: 50,
                            child: Transform.rotate(
                              angle: rotation,
                              child: const Icon(
                                Icons.airplanemode_active,
                                size: 40,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),

            Positioned(
              bottom: 100,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (authCubit.currentCountryCode != null)
                        CountryFlag.fromCountryCode(
                          authCubit.currentCountryCode!,
                          height: 20,
                          width: 30,
                        ),

                      if (authCubit.currentCountryCode != null)
                        const SizedBox(width: 8),

                      Text(
                        userInfoData.userCountry ??
                            authCubit.currentAddress.split(',')[0],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- زر "رحلة جديدة" ---
            Positioned(
              bottom: 20,
              child: ElevatedButton.icon(
                onPressed: _isFindingTrip ? null : _findNewTrip,
                icon: _isFindingTrip
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.flight_takeoff),
                label: const Text('رحلة جديدة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// دالة مساعدة لحساب زاوية دوران الطائرة (اختياري ولكن يجعلها أجمل)
double getRotation(LatLng start, LatLng end) {
  final dx = end.longitude - start.longitude;
  final dy = end.latitude - start.latitude;
  return -atan2(dx, dy); // استخدام atan2 لحساب الزاوية
}
