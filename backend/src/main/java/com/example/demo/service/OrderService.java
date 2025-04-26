package com.example.demo.service;

import com.example.demo.dto.OrderDto;
import com.example.demo.dto.UserDto;

import javax.transaction.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface OrderService {
    OrderDto createOrder(OrderDto dto, String username);
    List<OrderDto> getOrdersForClient(String username);
    OrderDto getOrderById(Long id, String username);
    void updateOrder(Long id, OrderDto updatedOrder);
    void assignBrigadier(Long orderId, String brigadierUsername);
   // void updateOrderStatus(Long id, String status);
    List<OrderDto> getAllOrders();
    Map<String, Long> getOrderCountPerDay(String username, LocalDate start, LocalDate end);
    List<UserDto> getAllBrigadiers();
    List<OrderDto> getOrdersForBrigadier(String username);
    @Transactional
    void updateOrderStatus(Long id, String status, String message);
}
