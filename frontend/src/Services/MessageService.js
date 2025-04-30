import ApiService from './BaseService/ApiService';

class MessageService {
  sendMessage(message) {
    return ApiService.post('/messages', message);
  }

  getMessagesForOrder(orderId, recipientUsername, senderUsername) {
    return ApiService.get(`/messages/${orderId}?recipientUsername=${recipientUsername}&senderUsername=${senderUsername}`);
  }
  getAdminUserDialogMessages(orderId, user) {
    return ApiService.get(`/messages/${orderId}/admin-dialog?user=${user}`);
  }
  getDialogMessages(orderId, user1, user2) {
    return ApiService.get(`/messages/${orderId}/dialog?user1=${user1}&user2=${user2}`);
  }
}

export default new MessageService();