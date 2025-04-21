package com.example.demo.service;

import com.example.demo.dto.OrderDto;
import java.util.List;

public interface OrderService {
    OrderDto createOrder(OrderDto dto, String username);
    List<OrderDto> getOrdersForClient(String username);
    OrderDto getOrderById(Long id, String username);
    void updateOrder(Long id, OrderDto updatedOrder);
    void assignBrigadier(Long orderId, String brigadierUsername);
    void updateOrderStatus(Long id, String status);
    List<OrderDto> getAllOrders();
}
