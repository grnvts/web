package com.example.demo.controller;

import com.example.demo.dto.OrderDto;
import com.example.demo.dto.UpdateStatusRequest;
import com.example.demo.dto.UserDto;
import com.example.demo.jwt.config.JwtTokenUtil;
import com.example.demo.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;
    private final JwtTokenUtil jwtTokenUtil;


//    @PutMapping("/{id}/status")
//    @PreAuthorize("hasRole('ADMIN')")
//    public ResponseEntity<?> updateOrderStatus(@PathVariable Long id, @RequestBody UpdateStatusRequest request) {
//        orderService.updateOrderStatus(id, request.getStatus());
//        return ResponseEntity.ok("Order status updated successfully");
//    }


    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<?> updateOrder(@PathVariable Long id, @RequestBody OrderDto updatedOrder) {
        orderService.updateOrder(id, updatedOrder);
        return ResponseEntity.ok("Order updated successfully");
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}/assign-brigadier")
    public ResponseEntity<?> assignBrigadier(@PathVariable Long id, @RequestBody Map<String, String> request) {
        orderService.assignBrigadier(id, request.get("username"));
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

    @GetMapping("/brigadier")
   @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public List<OrderDto> getBrigadierOrders(@RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrdersForBrigadier(username);
    }

    //Получение одного заказа по ID
   // @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    @GetMapping("/{id:[0-9]+}") // Ограничиваем {id} только цифрами, чтобы "my" не срабатывал как ID
    public OrderDto getOrder(@PathVariable Long id, @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrderById(id, username);
    }


    @GetMapping("/brigadier/{username}/calendar")
   // @PreAuthorize("hasRole('ADMIN')")
    public Map<String, Long> getBrigadierOrderCalendar(
            @PathVariable String username,
            @RequestParam String month // формат: "2025-04"
    ) {
        YearMonth yearMonth = YearMonth.parse(month);
        LocalDate start = yearMonth.atDay(1);
        LocalDate end = yearMonth.atEndOfMonth();
        return orderService.getOrderCountPerDay(username, start, end);
    }


    @GetMapping("/brigadiers")
    @PreAuthorize("hasRole('ADMIN')")
    public List<UserDto> getAllBrigadiers() {
        return orderService.getAllBrigadiers(); // Реализуем в сервисе
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> updateOrderStatus(
            @PathVariable Long id,
            @RequestBody UpdateStatusRequest request
    ) {
        orderService.updateOrderStatus(id, request.getStatus(), request.getMessage());
        return ResponseEntity.ok("Order status updated");
    }


    @GetMapping("/brigadier/active")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public List<OrderDto> getActiveOrdersForBrigadier(@RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        System.out.println("Username: " + username);
        System.out.println("Roles: " + SecurityContextHolder.getContext().getAuthentication().getAuthorities());
        return orderService.getActiveOrdersForBrigadier(username);
    }

    // работа с мастерами
    @GetMapping("/brigade/{brigadeId}/masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public List<UserDto> getBrigadeMasters(@PathVariable Long brigadeId) {
        return orderService.getBrigadeMasters(brigadeId);
    }

    @GetMapping("/{orderId}/assigned-masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public List<UserDto> getAssignedMasters(@PathVariable Long orderId) {
        return orderService.getAssignedMasters(orderId);
    }

    @PutMapping("/{orderId}/assign-masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> assignMasters(@PathVariable Long orderId, @RequestBody List<Long> masterIds) {
        orderService.assignMasters(orderId, masterIds);
        return ResponseEntity.ok("Masters assigned");
    }


}   
    