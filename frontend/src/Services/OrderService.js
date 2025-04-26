import ApiService from './BaseService/ApiService';

class OrderService {


  createOrder(orderData) {
    return ApiService.post('/orders', orderData);
  }
  
  getAllOrders() {
    return ApiService.get('/orders');
  }

  getMyOrders() {
    return ApiService.get('/orders/my'); 
  }
  getMyOrdersForBrigadier() {
    return ApiService.get('/orders/brigadier'); 
  }
 
  getOrderById(orderId) {
    return ApiService.get(`/orders/${orderId}`);
  }

  updateOrder(orderId, updatedOrder) {
    return ApiService.put(`/orders/${orderId}`, updatedOrder);
  }
  
 // updateOrderStatus(orderId, status) {
  //  return ApiService.put(`/orders/${orderId}/status`, status);
  //}

  updateOrderStatus(orderId, payload) {
    return ApiService.put(`/orders/${orderId}/status`, payload, {
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }
  
  
  getAllBrigadiers() {
    return ApiService.get('/orders/brigadiers');
  }
  
  getBrigadierCalendar(username, month) {
    return ApiService.get(`/orders/brigadier/${username}/calendar`, {
      params: {
        month: month
      },
      paramsSerializer: params => {
        return Object.keys(params)
          .map(key => `${key}=${encodeURIComponent(params[key])}`)
          .join('&');
      }
    });
  }
  
  assignBrigadier(orderId, brigadierUsername) {
    return ApiService.put(`/orders/${orderId}/assign-brigadier`, { username: brigadierUsername }, {
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }
  


}

export default new OrderService();