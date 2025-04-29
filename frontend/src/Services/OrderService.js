import ApiService from './BaseService/ApiService';
import Axios from "axios";
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
  getActiveOrdersForBrigadier() {
    console.log('Calling /orders/brigadier/active...');
    console.log('Authorization header:', Axios.defaults.headers.common['Authorization']);
    return ApiService.get('/orders/brigadier/active');
}
  getOrderById(orderId) {
    return ApiService.get(`/orders/${orderId}`);
  }

  getAssignedMasters(orderId) {
    return ApiService.get(`/orders/${orderId}/assigned-masters`);
  }

  assignMasters(orderId, masterIds) {
    return ApiService.put(`/orders/${orderId}/assign-masters`, masterIds);
  }
  
  updateOrder(orderId, updatedOrder) {
    return ApiService.put(`/orders/${orderId}`, updatedOrder);
  }
  addExpense(orderId, amount) {
    return ApiService.post(`/orders/${orderId}/add-expense`, { amount });
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