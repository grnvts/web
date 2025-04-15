package com.example.demo.controller;

import com.example.demo.dto.OrderDto;
import com.example.demo.jwt.config.JwtTokenUtil;
import com.example.demo.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final JwtTokenUtil jwtTokenUtil;

    @PostMapping
    public OrderDto createOrder(@RequestBody OrderDto dto, @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.createOrder(dto, username);
    }

    @GetMapping
    public List<OrderDto> getClientOrders(@RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrdersForClient(username);
    }

    @GetMapping("/{id}")
    public OrderDto getOrder(@PathVariable Long id, @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrderById(id, username);
    }
}
