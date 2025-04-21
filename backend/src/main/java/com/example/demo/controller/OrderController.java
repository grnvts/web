package com.example.demo.controller;

import com.example.demo.dto.OrderDto;
import com.example.demo.jwt.config.JwtTokenUtil;
import com.example.demo.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final JwtTokenUtil jwtTokenUtil;


    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateOrderStatus(@PathVariable Long id, @RequestBody String status) {
        orderService.updateOrderStatus(id, status);
        return ResponseEntity.ok("Order status updated successfully");
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<?> updateOrder(@PathVariable Long id, @RequestBody OrderDto updatedOrder) {
        orderService.updateOrder(id, updatedOrder);
        return ResponseEntity.ok("Order updated successfully");
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}/assign-brigadier")
    public ResponseEntity<?> assignBrigadier(@PathVariable Long id, @RequestBody String brigadierUsername) {
        orderService.assignBrigadier(id, brigadierUsername);
        return ResponseEntity.ok("Brigadier assigned successfully");
    }
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public List<OrderDto> getAllOrders() {
        return orderService.getAllOrders();
    }
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
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/{id:[0-9]+}") // Ограничиваем {id} только цифрами, чтобы "my" не срабатывал как ID
    public OrderDto getOrder(@PathVariable Long id, @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrderById(id, username);
    }
}
