package com.example.demo.controller;

import com.example.demo.dto.OrderDto;
import com.example.demo.dto.UpdateStatusRequest;
import com.example.demo.dto.UserDto;
import com.example.demo.jwt.config.JwtUserDetails;
import com.example.demo.model.Order;
import com.example.demo.service.OrderService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.ResponseEntity;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class OrderControllerTest {

    @Mock
    private OrderService orderService;

    @InjectMocks
    private OrderController orderController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testUpdateOrder() {
        Long orderId = 1L;
        OrderDto updatedOrder = new OrderDto();
        doNothing().when(orderService).updateOrder(orderId, updatedOrder);

        ResponseEntity<?> response = orderController.updateOrder(orderId, updatedOrder);

        assertEquals("Order updated successfully", response.getBody());
        verify(orderService, times(1)).updateOrder(orderId, updatedOrder);
    }

    @Test
    void testAssignBrigadier() {
        Long orderId = 1L;
        Map<String, String> request = Map.of("username", "brigadier1");
        doNothing().when(orderService).assignBrigadier(orderId, "brigadier1");

        ResponseEntity<?> response = orderController.assignBrigadier(orderId, request);

        assertEquals("Brigadier assigned successfully", response.getBody());
        verify(orderService, times(1)).assignBrigadier(orderId, "brigadier1");
    }

    @Test
    void testGetAllOrders() {
        List<OrderDto> orders = Arrays.asList(new OrderDto(), new OrderDto());
        when(orderService.getAllOrders()).thenReturn(orders);

        List<OrderDto> response = orderController.getAllOrders();

        assertEquals(2, response.size());
        verify(orderService, times(1)).getAllOrders();
    }

    @Test
    void testCreateOrder() {
        OrderDto orderDto = new OrderDto();
        JwtUserDetails principal = mock(JwtUserDetails.class);
        when(principal.getUsername()).thenReturn("user1");
        when(orderService.createOrder(orderDto, "user1")).thenReturn(orderDto);

        OrderDto response = orderController.createOrder(orderDto, principal);

        assertEquals(orderDto, response);
        verify(orderService, times(1)).createOrder(orderDto, "user1");
    }

    @Test
    void testGetClientOrders() {
        JwtUserDetails principal = mock(JwtUserDetails.class);
        String username = "client1";
        when(principal.getUsername()).thenReturn(username);
        List<OrderDto> orders = Arrays.asList(new OrderDto(), new OrderDto());
        when(orderService.getOrdersForClient(username)).thenReturn(orders);

        List<OrderDto> response = orderController.getClientOrders(principal);

        assertEquals(2, response.size());
        verify(orderService, times(1)).getOrdersForClient(username);
    }

    @Test
    void testGetBrigadierOrders() {
        JwtUserDetails principal = mock(JwtUserDetails.class);
        String username = "brigadier1";
        when(principal.getUsername()).thenReturn(username);
        List<OrderDto> orders = Arrays.asList(new OrderDto(), new OrderDto());
        when(orderService.getOrdersForBrigadier(username)).thenReturn(orders);

        List<OrderDto> response = orderController.getBrigadierOrders(principal);

        assertEquals(2, response.size());
        verify(orderService, times(1)).getOrdersForBrigadier(username);
    }

    @Test
    void testUpdateOrderStatus() {
        Long orderId = 1L;
        UpdateStatusRequest request = new UpdateStatusRequest("COMPLETED", "Order completed");
        doNothing().when(orderService).updateOrderStatus(orderId, "COMPLETED", "Order completed");

        ResponseEntity<?> response = orderController.updateOrderStatus(orderId, request);

        assertEquals("Order status updated", response.getBody());
        verify(orderService, times(1)).updateOrderStatus(orderId, "COMPLETED", "Order completed");
    }

    @Test
    void testGetActiveOrdersForBrigadier() {
        JwtUserDetails principal = mock(JwtUserDetails.class);
        String username = "brigadier1";
        when(principal.getUsername()).thenReturn(username);
        List<OrderDto> orders = Arrays.asList(new OrderDto(), new OrderDto());
        when(orderService.getActiveOrdersForBrigadier(username)).thenReturn(orders);

        List<OrderDto> response = orderController.getActiveOrdersForBrigadier(principal);

        assertEquals(2, response.size());
        verify(orderService, times(1)).getActiveOrdersForBrigadier(username);
    }

    @Test
    void testAssignMasters() {
        Long orderId = 1L;
        List<Long> masterIds = Arrays.asList(1L, 2L);
        doNothing().when(orderService).assignMasters(orderId, masterIds);

        ResponseEntity<?> response = orderController.assignMasters(orderId, masterIds);

        assertEquals("Masters assigned", response.getBody());
        verify(orderService, times(1)).assignMasters(orderId, masterIds);
    }

    @Test
    void testAddExpense() {
        Long orderId = 1L;
        Map<String, Double> body = Map.of("amount", 100.0);
        Order order = new Order();
        OrderDto orderDto = new OrderDto(order);
        when(orderService.addExpense(orderId, 100.0)).thenReturn(order);

        ResponseEntity<?> response = orderController.addExpense(orderId, body);

        assertEquals(orderDto, response.getBody());
        verify(orderService, times(1)).addExpense(orderId, 100.0);
    }
}
