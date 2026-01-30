package com.example.demo.domain.orders.service;

import com.example.demo.domain.common.error.NotFoundException;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.orders.port.NotificationPort;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.orders.repo.OrderRepository;
import com.example.demo.domain.orders.repo.BrigadeRepository;
import com.example.demo.domain.users.port.UserAccessPort;
import com.example.demo.domain.orders.service.impl.OrderServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.modelmapper.ModelMapper;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OrderServiceImplTest {

    @Mock
    OrderRepository orderRepository;
    @Mock
    UserAccessPort userAccessPort;
    @Mock
    NotificationPort notificationPort;
    @Mock
    BrigadeRepository brigadeRepository;

    @InjectMocks
    OrderServiceImpl service;

    @BeforeEach
    void init() {
        service = new OrderServiceImpl(orderRepository, userAccessPort, new ModelMapper(), notificationPort, brigadeRepository);
    }

    @Test
    void getOrderById_whenMissing_shouldThrowNotFound() {
        when(orderRepository.findByIdWithBrigadier(1L)).thenReturn(Optional.empty());
        assertThrows(NotFoundException.class, () -> service.getOrderById(1L, "user"));
    }

    @Test
    void addExpense_whenOrderMissing_shouldThrow() {
        when(orderRepository.findById(1L)).thenReturn(Optional.empty());
        assertThrows(NotFoundException.class, () -> service.addExpense(1L, 10.0));
    }

    @Test
    void assignBrigadier_whenBrigadierNotFound_shouldThrow() {
        when(orderRepository.findById(1L)).thenReturn(Optional.of(new Order()));
        when(userAccessPort.findByUsername("missing")).thenReturn(null);
        assertThrows(RuntimeException.class, () -> service.assignBrigadier(1L, "missing"));
    }
}
