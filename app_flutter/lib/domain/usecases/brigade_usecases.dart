import '../repositories/brigade_repository.dart';

class BrigadeUseCases {
  final BrigadeRepository _repository;

  const BrigadeUseCases(this._repository);

  Future<List<dynamic>> getAllBrigades() => _repository.getAllBrigades();

  Future<List<dynamic>> getAllMasters() => _repository.getAllMasters();

  Future<List<dynamic>> getMyBrigadeMasters() =>
      _repository.getMyBrigadeMasters();

  Future<List<dynamic>> getBrigadeMasters(int brigadeId) =>
      _repository.getBrigadeMasters(brigadeId);

  Future<void> addMasterToBrigade(int brigadeId, int userId) =>
      _repository.addMasterToBrigade(brigadeId, userId);

  Future<void> removeMasterFromBrigade(int brigadeId, int userId) =>
      _repository.removeMasterFromBrigade(brigadeId, userId);

  Future<void> addMasterToMyBrigade(int userId) =>
      _repository.addMasterToMyBrigade(userId);

  Future<void> removeMasterFromMyBrigade(int userId) =>
      _repository.removeMasterFromMyBrigade(userId);
}
