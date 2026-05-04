abstract class BrigadeRepository {
  Future<List<dynamic>> getAllBrigades();

  Future<List<dynamic>> getAllMasters();

  Future<List<dynamic>> getMyBrigadeMasters();

  Future<List<dynamic>> getBrigadeMasters(int brigadeId);

  Future<void> addMasterToBrigade(int brigadeId, int userId);

  Future<void> removeMasterFromBrigade(int brigadeId, int userId);

  Future<void> addMasterToMyBrigade(int userId);

  Future<void> removeMasterFromMyBrigade(int userId);
}
