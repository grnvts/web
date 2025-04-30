package com.example.demo.service;

import com.example.demo.dto.OrderDto;
import com.example.demo.model.Order;
import com.example.demo.model.Role;
import com.example.demo.model.RoleName;
import com.example.demo.model.User;
import com.example.demo.repo.OrderRepository;
import com.example.demo.repo.UserRepository;
import com.example.demo.service.impl.OrderServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class OrderServiceTest {

    @InjectMocks
    private OrderServiceImpl orderService;

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private UserRepository userRepository;

    @Test
    public void testGetOrderById() {
        // Arrange
        User user = new User();
        user.setId(1L);
        user.setUsername("testuser");
        Role role = new Role();
        role.setName(RoleName.ROLE_USER);
        user.setRoles(Collections.singleton(role));

        Order order = new Order();
        order.setId(1L);
        order.setClient(user);

        when(userRepository.findByUsername("testuser")).thenReturn(user);
        when(orderRepository.findByIdWithBrigadier(1L)).thenReturn(Optional.of(order));

        // Act
        OrderDto result = orderService.getOrderById(1L, "testuser");

        // Assert
        assertEquals(1L, result.getId());
        assertEquals("testuser", result.getClientUsername());
    }
}