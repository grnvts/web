package com.example.demo.service;

import com.example.demo.error.NotFoundException;
import com.example.demo.repo.BrigadeRepository;
import com.example.demo.repo.OrderRepository;
import com.example.demo.repo.UserRepository;
import com.example.demo.service.impl.OrderServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.modelmapper.ModelMapper;
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
    UserRepository userRepository;
    @Mock
    NotificationService notificationService;
    @Mock
    BrigadeRepository brigadeRepository;

    private OrderServiceImpl service;

    @BeforeEach
    void setUp() {
        service = new OrderServiceImpl(
                orderRepository,
                userRepository,
                new ModelMapper(),
                notificationService,
                brigadeRepository
        );
    }

    @Test
    void getOrderById_shouldThrow_whenOrderMissing() {
        when(orderRepository.findByIdWithBrigadier(42L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> service.getOrderById(42L, "user"));
    }
}
