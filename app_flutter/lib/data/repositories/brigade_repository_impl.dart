import '../../domain/repositories/brigade_repository.dart';
import '../datasources/brigade_service.dart';

class BrigadeRepositoryImpl implements BrigadeRepository {
  final BrigadeService _dataSource;

  const BrigadeRepositoryImpl(this._dataSource);

  @override
  Future<List<dynamic>> getAllBrigades() => _dataSource.getAllBrigades();

  @override
  Future<List<dynamic>> getAllMasters() => _dataSource.getAllMasters();

  @override
  Future<List<dynamic>> getMyBrigadeMasters() =>
      _dataSource.getMyBrigadeMasters();

  @override
  Future<List<dynamic>> getBrigadeMasters(int brigadeId) =>
      _dataSource.getBrigadeMasters(brigadeId);

  @override
  Future<void> addMasterToBrigade(int brigadeId, int userId) =>
      _dataSource.addMasterToBrigade(brigadeId, userId);

  @override
  Future<void> removeMasterFromBrigade(int brigadeId, int userId) =>
      _dataSource.removeMasterFromBrigade(brigadeId, userId);

  @override
  Future<void> addMasterToMyBrigade(int userId) =>
      _dataSource.addMasterToMyBrigade(userId);

  @override
  Future<void> removeMasterFromMyBrigade(int userId) =>
      _dataSource.removeMasterFromMyBrigade(userId);
}
