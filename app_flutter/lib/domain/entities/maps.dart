import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocation {
  final double lat;
  final double lng;
  final String formattedAddress;

  const MapLocation({
    required this.lat,
    required this.lng,
    required this.formattedAddress,
  });

  LatLng toLatLng() => LatLng(lat, lng);
}

class AutocompleteSuggestion {
  final String description;
  final String placeId;

  const AutocompleteSuggestion({
    required this.description,
    required this.placeId,
  });
}

class NearbyPlace {
  final String name;
  final double lat;
  final double lng;

  const NearbyPlace({
    required this.name,
    required this.lat,
    required this.lng,
  });

  LatLng toLatLng() => LatLng(lat, lng);
}

class DirectionDetails {
  final List<LatLng> polyline;
  final String distanceText;
  final String durationText;

  const DirectionDetails({
    required this.polyline,
    required this.distanceText,
    required this.durationText,
  });
}
