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



    //Создание заказа
    @PostMapping
    public OrderDto createOrder(@RequestBody OrderDto dto, @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.createOrder(dto, username);
    }

    //Получение заказов текущего пользователя
    @GetMapping("/my")
    public List<OrderDto> getClientOrders(@RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrdersForClient(username);
    }

    //Получение одного заказа по ID
    @GetMapping("/{id:[0-9]+}") // Ограничиваем {id} только цифрами, чтобы "my" не срабатывал как ID
    public OrderDto getOrder(@PathVariable Long id, @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrderById(id, username);
    }
}
