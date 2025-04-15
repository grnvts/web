package com.example.demo.service;

import com.example.demo.dto.OrderDto;
import java.util.List;

public interface OrderService {
    OrderDto createOrder(OrderDto dto, String username);
    List<OrderDto> getOrdersForClient(String username);
    OrderDto getOrderById(Long id, String username);
}
