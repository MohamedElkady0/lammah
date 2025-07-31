import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lammah/core/utils/chat_string.dart';
import 'package:lammah/core/utils/string_app.dart';
import 'package:lammah/fetcher/domian/auth/auth_cubit.dart';
import 'package:latlong2/latlong.dart';
import 'package:transparent_image/transparent_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthCubit>(context).getCurrentLocation();
    _mapController =
        BlocProvider.of<AuthCubit>(context).mapController ?? MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.of<AuthCubit>(context).isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter:
                      BlocProvider.of<AuthCubit>(context).currentPosition ??
                      const LatLng(51.5, -0.09),
                  initialZoom: 2.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: ChatString.mapImg,
                    userAgentPackageName: StringApp.packageName,
                  ),
                  if (BlocProvider.of<AuthCubit>(context).currentPosition !=
                      null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 60.0,
                          height: 60.0,
                          point: BlocProvider.of<AuthCubit>(
                            context,
                          ).currentPosition!,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue,
                            backgroundImage:
                                BlocProvider.of<AuthCubit>(
                                      context,
                                    ).currentUserInfo?.image !=
                                    null
                                ? NetworkImage(
                                    BlocProvider.of<AuthCubit>(
                                      context,
                                    ).currentUserInfo!.image!,
                                  )
                                : MemoryImage(kTransparentImage),
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
                      BlocProvider.of<AuthCubit>(
                        context,
                      ).currentAddress.split(',')[0],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
