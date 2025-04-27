import ApiService from './BaseService/ApiService';

class MessageService {
  sendMessage(message) {
    return ApiService.post('/messages', message);
  }

  getMessagesForOrder(orderId) {
    return ApiService.get(`/messages/${orderId}`);
  }
}

export default new MessageService();