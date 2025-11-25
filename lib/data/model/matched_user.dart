import 'package:latlong2/latlong.dart';

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
