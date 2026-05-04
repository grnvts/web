package com.example.demo.domain.orders.controller;

import com.example.demo.domain.orders.dto.OrderDto;
import com.example.demo.domain.orders.dto.UpdateStatusRequest;
import com.example.demo.domain.users.dto.UserDto;
import com.example.demo.domain.common.config.jwt.JwtUserDetails;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.orders.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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
    public OrderDto createOrder(@RequestBody OrderDto dto, @AuthenticationPrincipal JwtUserDetails user) {
        return orderService.createOrder(dto, user.getUsername());
    }

    @Operation(summary = "Get client orders", description = "Retrieve orders for the authenticated client")
    @GetMapping("/my")
    public List<OrderDto> getClientOrders(@AuthenticationPrincipal JwtUserDetails user) {
        return orderService.getOrdersForClient(user.getUsername());
    }

    @Operation(summary = "Get brigadier orders", description = "Retrieve orders assigned to the authenticated brigadier")
    @GetMapping("/brigadier")
    @PreAuthorize("hasRole('BRIGADIER')")
    public List<OrderDto> getBrigadierOrders(@AuthenticationPrincipal JwtUserDetails user) {
        return orderService.getOrdersForBrigadier(user.getUsername());
    }

    @Operation(summary = "Get order by ID", description = "Retrieve an order by its ID")
    @GetMapping("/{id:[0-9]+}")
    public OrderDto getOrder(@PathVariable Long id, @AuthenticationPrincipal JwtUserDetails user) {
        return orderService.getOrderById(id, user.getUsername());
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
    @PreAuthorize("hasAnyRole('BRIGADIER','ADMIN','USER')")
    public ResponseEntity<?> updateOrderStatus(
            @PathVariable Long id,
            @AuthenticationPrincipal JwtUserDetails user,
            @RequestBody UpdateStatusRequest request
    ) {
        orderService.updateOrderStatus(id, user.getUsername(), request.getStatus(), request.getMessage());
        return ResponseEntity.ok("Order status updated");
    }

    @Operation(summary = "Get active orders for brigadier", description = "Retrieve active orders for the authenticated brigadier")
    @GetMapping("/brigadier/active")
    @PreAuthorize("hasRole('BRIGADIER')")
    public List<OrderDto> getActiveOrdersForBrigadier(@AuthenticationPrincipal JwtUserDetails user) {
        return orderService.getActiveOrdersForBrigadier(user.getUsername());
    }

    @Operation(summary = "Get brigade masters", description = "Retrieve masters in a specific brigade")
    @GetMapping("/brigade/{brigadeId}/masters")
    @PreAuthorize("hasAnyRole('BRIGADIER','ADMIN')")
    public List<UserDto> getBrigadeMasters(@PathVariable Long brigadeId) {
        return orderService.getBrigadeMasters(brigadeId);
    }

    @Operation(summary = "Get assigned masters", description = "Retrieve masters assigned to a specific order")
    @GetMapping("/{orderId}/assigned-masters")
    @PreAuthorize("hasAnyRole('BRIGADIER','ADMIN','USER')")
    public List<UserDto> getAssignedMasters(
            @PathVariable Long orderId,
            @AuthenticationPrincipal JwtUserDetails user) {
        return orderService.getAssignedMasters(orderId, user.getUsername());
    }

    @Operation(summary = "Assign masters to an order", description = "Assign masters to a specific order")
    @PutMapping("/{orderId}/assign-masters")
    @PreAuthorize("hasAnyRole('BRIGADIER','ADMIN')")
    public ResponseEntity<?> assignMasters(@PathVariable Long orderId, @RequestBody List<Long> masterIds) {
        orderService.assignMasters(orderId, masterIds);
        return ResponseEntity.ok("Masters assigned");
    }

    @Operation(summary = "Add expense to an order", description = "Add an expense to a specific order")
    @PostMapping("/{orderId}/add-expense")
    @PreAuthorize("hasAnyRole('BRIGADIER','ADMIN')")
    public ResponseEntity<?> addExpense(
            @PathVariable Long orderId,
            @AuthenticationPrincipal JwtUserDetails user,
            @RequestBody Map<String, Double> body) {
        Double amount = body.get("amount");
        try {
            Order order = orderService.addExpense(orderId, user.getUsername(), amount);
            OrderDto dto = new OrderDto(order);
            return ResponseEntity.ok(dto);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
