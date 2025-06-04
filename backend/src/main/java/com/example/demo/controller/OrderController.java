package com.example.demo.controller;

import com.example.demo.dto.OrderDto;
import com.example.demo.dto.UpdateStatusRequest;
import com.example.demo.dto.UserDto;
import com.example.demo.jwt.config.JwtTokenUtil;
import com.example.demo.model.Order;
import com.example.demo.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
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

    @Operation(summary = "Update an order", description = "Update an existing order by ID")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}")
    public ResponseEntity<?> updateOrder(@PathVariable Long id, @RequestBody OrderDto updatedOrder) {
        orderService.updateOrder(id, updatedOrder);
        return ResponseEntity.ok("Order updated successfully");
    }

    @Operation(summary = "Assign a brigadier", description = "Assign a brigadier to an order by ID")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}/assign-brigadier")
    public ResponseEntity<?> assignBrigadier(@PathVariable Long id, @RequestBody Map<String, String> request) {
        orderService.assignBrigadier(id, request.get("username"));
        return ResponseEntity.ok("Brigadier assigned successfully");
    }

    @Operation(summary = "Get all orders", description = "Retrieve a list of all orders")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public List<OrderDto> getAllOrders() {
        return orderService.getAllOrders();
    }

    @Operation(summary = "Create a new order", description = "Create a new order for the authenticated user")
    @PostMapping
    public OrderDto createOrder(@RequestBody OrderDto dto, @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.createOrder(dto, username);
    }

    @Operation(summary = "Get client orders", description = "Retrieve orders for the authenticated client")
    @GetMapping("/my")
    public List<OrderDto> getClientOrders(@RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrdersForClient(username);
    }

    @Operation(summary = "Get brigadier orders", description = "Retrieve orders assigned to the authenticated brigadier")
    @GetMapping("/brigadier")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public List<OrderDto> getBrigadierOrders(@RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrdersForBrigadier(username);
    }

    @Operation(summary = "Get order by ID", description = "Retrieve an order by its ID")
    @GetMapping("/{id:[0-9]+}")
    public OrderDto getOrder(@PathVariable Long id, @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getOrderById(id, username);
    }

    @Operation(summary = "Get brigadier order calendar", description = "Retrieve the order calendar for a brigadier")
    @GetMapping("/brigadier/{username}/calendar")
    @PreAuthorize("hasRole('ADMIN')")
    public Map<String, Long> getBrigadierOrderCalendar(
            @PathVariable String username,
            @RequestParam String month // формат: "2025-04"
    ) {
        YearMonth yearMonth = YearMonth.parse(month);
        LocalDate start = yearMonth.atDay(1);
        LocalDate end = yearMonth.atEndOfMonth();
        return orderService.getOrderCountPerDay(username, start, end);
    }

    @Operation(summary = "Get all brigadiers", description = "Retrieve a list of all brigadiers")
    @GetMapping("/brigadiers")
    @PreAuthorize("hasRole('ADMIN')")
    public List<UserDto> getAllBrigadiers() {
        return orderService.getAllBrigadiers();
    }

    @Operation(summary = "Update order status", description = "Update the status of an order")
    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
    public ResponseEntity<?> updateOrderStatus(
            @PathVariable Long id,
            @RequestBody UpdateStatusRequest request
    ) {
        orderService.updateOrderStatus(id, request.getStatus(), request.getMessage());
        return ResponseEntity.ok("Order status updated");
    }

    @Operation(summary = "Get active orders for brigadier", description = "Retrieve active orders for the authenticated brigadier")
    @GetMapping("/brigadier/active")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public List<OrderDto> getActiveOrdersForBrigadier(@RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        return orderService.getActiveOrdersForBrigadier(username);
    }

    @Operation(summary = "Get brigade masters", description = "Retrieve masters in a specific brigade")
    @GetMapping("/brigade/{brigadeId}/masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public List<UserDto> getBrigadeMasters(@PathVariable Long brigadeId) {
        return orderService.getBrigadeMasters(brigadeId);
    }

    @Operation(summary = "Get assigned masters", description = "Retrieve masters assigned to a specific order")
    @GetMapping("/{orderId}/assigned-masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public List<UserDto> getAssignedMasters(@PathVariable Long orderId) {
        return orderService.getAssignedMasters(orderId);
    }

    @Operation(summary = "Assign masters to an order", description = "Assign masters to a specific order")
    @PutMapping("/{orderId}/assign-masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> assignMasters(@PathVariable Long orderId, @RequestBody List<Long> masterIds) {
        orderService.assignMasters(orderId, masterIds);
        return ResponseEntity.ok("Masters assigned");
    }

    @Operation(summary = "Add expense to an order", description = "Add an expense to a specific order")
    @PostMapping("/{orderId}/add-expense")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public ResponseEntity<?> addExpense(@PathVariable Long orderId, @RequestBody Map<String, Double> body) {
        Double amount = body.get("amount");
        try {
            Order order = orderService.addExpense(orderId, amount);
            OrderDto dto = new OrderDto(order);
            return ResponseEntity.ok(dto);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}