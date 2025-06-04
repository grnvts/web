package com.example.demo.service;

import com.example.demo.dto.AddressDto;
import com.example.demo.dto.OrderDto;
import com.example.demo.dto.UserDto;
import com.example.demo.error.NotFoundException;
import com.example.demo.model.*;
import com.example.demo.repo.*;
import com.example.demo.service.impl.OrderServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.*;

class OrderServiceImplTest {

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private AddressRepository addressRepository;

    @Mock
    private BrigadeRepository brigadeRepository;

    @Mock
    private NotificationService notificationService;

    @InjectMocks
    private OrderServiceImpl orderService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }


    @Test
    void testGetOrdersForClient() {
        String username = "testUser";
        User client = new User();
        client.setUsername(username);

        Order order = new Order();
        order.setClient(client);

        when(userRepository.findUserByUsernameWithStatusOne(username)).thenReturn(client);
        when(orderRepository.findByClient(client)).thenReturn(Collections.singletonList(order));

        List<OrderDto> result = orderService.getOrdersForClient(username);

        assertThat(result).hasSize(1);
        verify(orderRepository, times(1)).findByClient(client);
    }

    @Test
    void testGetOrderById() {
        Long orderId = 1L;
        String username = "testUser";

        User client = new User();
        client.setUsername(username);

        Order order = new Order();
        order.setId(orderId);
        order.setClient(client);

        when(orderRepository.findByIdWithBrigadier(orderId)).thenReturn(Optional.of(order));
        when(userRepository.findByUsername(username)).thenReturn(client);

        OrderDto result = orderService.getOrderById(orderId, username);

        assertThat(result).isNotNull();
        assertThat(result.getId()).isEqualTo(orderId);
    }






    @Test
    void testGetOrderCountPerDay() {
        String username = "brigadierUser";
        LocalDate start = LocalDate.now().minusDays(5);
        LocalDate end = LocalDate.now();

        Object[] row = {LocalDate.now(), 3L};
        when(orderRepository.countOrdersByBrigadierPerDay(username, start, end))
                .thenReturn(Collections.singletonList(row));

        Map<String, Long> result = orderService.getOrderCountPerDay(username, start, end);

        assertThat(result).hasSize(1);
        assertThat(result.get(LocalDate.now().toString())).isEqualTo(3L);
    }

    @Test
    void testAddExpense() {
        Long orderId = 1L;
        Double amount = 100.0;

        Order order = new Order();
        order.setPrice(BigDecimal.valueOf(200.0));

        when(orderRepository.findById(orderId)).thenReturn(Optional.of(order));

        Order result = orderService.addExpense(orderId, amount);

        assertThat(result.getPrice()).isEqualTo(BigDecimal.valueOf(300.0));
        verify(orderRepository, times(1)).save(order);
    }

    @Test
    void testAddExpense_InvalidAmount() {
        Long orderId = 1L;
        Double amount = -50.0;

        assertThrows(IllegalArgumentException.class, () -> orderService.addExpense(orderId, amount));
    }
}