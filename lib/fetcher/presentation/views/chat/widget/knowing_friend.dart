import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lammah/core/utils/chat_string.dart';
import 'package:lammah/core/utils/string_app.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:circle_flags/circle_flags.dart';
import 'package:country_flags/country_flags.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();

  bool _isMapReady = false;

  LatLng? _pendingPosition;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getCurrentLocation();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LocationUpdateSuccess) {
          final authCubit = context.read<AuthCubit>();
          final positionToMove = authCubit.countryPosition ?? state.position;

          if (_isMapReady) {
            mapController.move(positionToMove, 2.0);
          } else {
            _pendingPosition = positionToMove;
          }
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final authCubit = context.read<AuthCubit>();
          final positionForMap =
              authCubit.countryPosition ?? authCubit.currentPosition;
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
                  onMapReady: () {
                    setState(() {
                      _isMapReady = true;
                    });
                    if (_pendingPosition != null) {
                      mapController.move(_pendingPosition!, 2.0);
                      _pendingPosition = null;
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: ChatString.mapImg,
                    userAgentPackageName: StringApp.packageName,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 60.0,
                        height: 60.0,
                        point: positionForMap,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (authCubit.currentCountryCode != null)
                              CircleFlag(
                                authCubit.currentCountryCode!,
                                size: 60,
                              ),

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
                    ],
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
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
