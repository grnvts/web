import '../../domain/entities/maps.dart';
import '../../domain/repositories/maps_repository.dart';
import '../datasources/google_maps_service.dart';

class MapsRepositoryImpl implements MapsRepository {
  final GoogleMapsService _dataSource;

  const MapsRepositoryImpl(this._dataSource);

  @override
  Future<MapLocation> getCoordinates(String address) =>
      _dataSource.getCoordinates(address);

  @override
  Future<List<NearbyPlace>> searchNearbyPlaces(
    MapLocation location, {
    int radius = 1000,
  }) =>
      _dataSource.searchNearbyPlaces(location, radius: radius);

  @override
  Future<List<AutocompleteSuggestion>> getAutocompleteSuggestions(
    String input,
  ) =>
      _dataSource.getAutocompleteSuggestions(input);

  @override
  Future<DirectionDetails> getDirections({
    required String origin,
    required String destination,
  }) =>
      _dataSource.getDirections(origin: origin, destination: destination);

  @override
  String getStreetViewUrl(MapLocation location) =>
      _dataSource.getStreetViewUrl(location);
}
