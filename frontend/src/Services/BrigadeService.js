import ApiService from "./BaseService/ApiService";

class BrigadeService {
    getBrigadeMasters(brigadeId) {
        return ApiService.get(`/orders/brigade/${brigadeId}/masters`);
    }
    getAllMasters() {
        return ApiService.get('/user/masters');
    }
    addMasterToBrigade(brigadeId, userId) {
        return ApiService.post(`/brigade/${brigadeId}/add-master`, { userId });
    }
    removeMasterFromBrigade(brigadeId, userId) {
        return ApiService.post(`/brigade/${brigadeId}/remove-master`, { userId });
    }

    getAllBrigades() {
        return ApiService.get('/brigade/all');
    }
    getMyBrigadeMasters() {
        return ApiService.get('/brigade/my/masters');
    }
    addMasterToMyBrigade(userId) {
        return ApiService.post('/brigade/my/add-master', { userId });
    }
    removeMasterFromMyBrigade(userId) {
        return ApiService.post('/brigade/my/remove-master', { userId });
    }
}

export default new BrigadeService();