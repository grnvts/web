import ApiService from './BaseService/ApiService';

class OrderService {
  getBuildings() {
    return ApiService.get('/buildings');
  }

  createOrder(orderData) {
    return ApiService.post('/orders', orderData);
  }

  getMyOrders() {
    return ApiService.get('/orders/my');
  }

  getOrderById(orderId) {
    return ApiService.get(`/orders/${orderId}`);
  }
}

export default new OrderService();