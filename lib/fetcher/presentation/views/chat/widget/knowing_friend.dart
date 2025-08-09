import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lammah/core/utils/chat_string.dart';
import 'package:lammah/core/utils/string_app.dart';
import 'package:lammah/fetcher/data/model/user_info.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:transparent_image/transparent_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.userInfoData});
  final UserInfoData userInfoData;

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
          if (_isMapReady) {
            mapController.move(state.position, 2.0);
          } else {
            _pendingPosition = state.position;
          }
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final authCubit = context.read<AuthCubit>();
          final currentPosition = authCubit.currentPosition;

          if (currentPosition == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: currentPosition,
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
                        point: currentPosition,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue,
                          backgroundImage: widget.userInfoData.image != null
                              ? NetworkImage(widget.userInfoData.image!)
                              : MemoryImage(kTransparentImage) as ImageProvider,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 80,
                left: MediaQuery.of(context).size.width * 0.27,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.userInfoData.userCity ?? 'Unknown Location',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
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
