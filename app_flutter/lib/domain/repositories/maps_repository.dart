import '../entities/maps.dart';

abstract class MapsRepository {
  Future<MapLocation> getCoordinates(String address);

  Future<List<NearbyPlace>> searchNearbyPlaces(
    MapLocation location, {
    int radius = 1000,
  });

  Future<List<AutocompleteSuggestion>> getAutocompleteSuggestions(String input);

  Future<DirectionDetails> getDirections({
    required String origin,
    required String destination,
  });

  String getStreetViewUrl(MapLocation location);
}
