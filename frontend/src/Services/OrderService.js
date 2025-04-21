import ApiService from './BaseService/ApiService';

class OrderService {


  createOrder(orderData) {
    return ApiService.post('/orders', orderData);
  }
  
  getAllOrders() {
    return ApiService.get('/orders');
  }

  getMyOrders() {
    return ApiService.get('/orders/my', {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    });
  }

  getOrderById(orderId) {
    return ApiService.get(`/orders/${orderId}`);
  }

  updateOrderStatus(orderId, status) {
    return ApiService.put(`/orders/${orderId}/status`, status);
  }

  updateOrder(orderId, updatedOrder) {
    return ApiService.put(`/orders/${orderId}`, updatedOrder);
  }

  assignBrigadier(orderId, brigadierUsername) {
    return ApiService.put(`/orders/${orderId}/assign-brigadier`, brigadierUsername);
  }
}

export default new OrderService();