import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/config/app_config.dart';
import '../../domain/entities/maps.dart';

class GoogleMapsService {
  static const String _geocodeUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';
  static const String _directionsUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const String _placesNearbyUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const String _placesAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  final String _apiKey = AppConfig.googleMapsApiKey;

  void _ensureKey() {
    if (_apiKey.trim().isEmpty) {
      throw Exception('Google Maps API key is not configured.');
    }
  }

  Future<MapLocation> getCoordinates(String address) async {
    _ensureKey();
    final uri = Uri.parse(
      '$_geocodeUrl?address=${Uri.encodeComponent(address)}&region=by&key=$_apiKey',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to reach geocoding service.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK' || (data['results'] as List).isEmpty) {
      throw Exception('Unable to resolve the address.');
    }

    final first = (data['results'] as List).first as Map<String, dynamic>;
    final location = (first['geometry'] as Map<String, dynamic>)['location']
        as Map<String, dynamic>;
    return MapLocation(
      lat: (location['lat'] as num).toDouble(),
      lng: (location['lng'] as num).toDouble(),
      formattedAddress: first['formatted_address']?.toString() ?? address,
    );
  }

  Future<List<NearbyPlace>> searchNearbyPlaces(
    MapLocation location, {
    int radius = 1000,
  }) async {
    _ensureKey();
    final uri = Uri.parse(
      '$_placesNearbyUrl?location=${location.lat},${location.lng}&radius=$radius&type=store&keyword=business&key=$_apiKey',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load nearby places.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception('Unable to find nearby places.');
    }

    final results = (data['results'] as List? ?? const <dynamic>[]);
    return results
        .map((item) {
          final map = item as Map<String, dynamic>;
          final geometry = map['geometry'] as Map<String, dynamic>?;
          final loc = geometry?['location'] as Map<String, dynamic>?;
          if (loc == null) return null;
          return NearbyPlace(
            name: map['name']?.toString() ?? 'Nearby place',
            lat: (loc['lat'] as num).toDouble(),
            lng: (loc['lng'] as num).toDouble(),
          );
        })
        .whereType<NearbyPlace>()
        .toList(growable: false);
  }

  Future<List<AutocompleteSuggestion>> getAutocompleteSuggestions(
    String input,
  ) async {
    _ensureKey();
    final uri = Uri.parse(
      '$_placesAutocompleteUrl?input=${Uri.encodeComponent(input)}&components=country:by&types=address&language=en&key=$_apiKey',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load suggestions.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception('No suggestions found.');
    }

    final predictions = (data['predictions'] as List? ?? const <dynamic>[]);
    return predictions
        .map(
          (item) => AutocompleteSuggestion(
            description: item['description']?.toString() ?? '',
            placeId: item['place_id']?.toString() ?? '',
          ),
        )
        .where((item) => item.description.isNotEmpty)
        .toList(growable: false);
  }

  Future<DirectionDetails> getDirections({
    required String origin,
    required String destination,
  }) async {
    _ensureKey();
    final uri = Uri.parse(
      '$_directionsUrl?origin=${Uri.encodeComponent(origin)}&destination=${Uri.encodeComponent(destination)}&mode=driving&region=by&language=en&key=$_apiKey',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load directions.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK' || (data['routes'] as List).isEmpty) {
      throw Exception('Route not available.');
    }

    final route = (data['routes'] as List).first as Map<String, dynamic>;
    final leg = (route['legs'] as List).first as Map<String, dynamic>;
    final distanceText =
        (leg['distance'] as Map<String, dynamic>)['text']?.toString() ??
            'Unknown';
    final durationText =
        (leg['duration'] as Map<String, dynamic>)['text']?.toString() ??
            'Unknown';
    final polyline = route['overview_polyline']?['points']?.toString() ?? '';

    return DirectionDetails(
      polyline: _decodePolyline(polyline),
      distanceText: distanceText,
      durationText: durationText,
    );
  }

  String getStreetViewUrl(MapLocation location) {
    _ensureKey();
    return 'https://maps.googleapis.com/maps/api/streetview?size=600x300&location=${location.lat},${location.lng}&key=$_apiKey';
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
