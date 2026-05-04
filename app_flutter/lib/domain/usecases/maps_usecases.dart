import '../entities/maps.dart';
import '../repositories/maps_repository.dart';

class MapsUseCases {
  final MapsRepository _repository;

  const MapsUseCases(this._repository);

  Future<MapLocation> getCoordinates(String address) =>
      _repository.getCoordinates(address);

  Future<List<NearbyPlace>> searchNearbyPlaces(
    MapLocation location, {
    int radius = 1000,
  }) =>
      _repository.searchNearbyPlaces(location, radius: radius);

  Future<List<AutocompleteSuggestion>> getAutocompleteSuggestions(
    String input,
  ) =>
      _repository.getAutocompleteSuggestions(input);

  Future<DirectionDetails> getDirections({
    required String origin,
    required String destination,
  }) =>
      _repository.getDirections(origin: origin, destination: destination);

  String getStreetViewUrl(MapLocation location) =>
      _repository.getStreetViewUrl(location);
}
