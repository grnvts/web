package com.example.demo.service;

import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.orders.port.AddressRepositoryPort;
import com.example.demo.domain.orders.port.BrigadeRepositoryPort;
import com.example.demo.domain.orders.port.NotificationPort;
import com.example.demo.domain.orders.port.OrderRepositoryPort;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;
import com.example.demo.domain.orders.service.impl.OrderServiceImpl;
import org.modelmapper.ModelMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class OrderServiceAssignMastersTest {

    @InjectMocks
    private OrderServiceImpl orderService;

    @Mock
    private OrderRepositoryPort orderRepository;

    @Mock
    private UserAccessPort userAccessPort;

    @Mock
    private NotificationPort notificationPort;

    @Mock
    private BrigadeRepositoryPort brigadeRepository;

    @Mock
    private AddressRepositoryPort addressRepository;

    private final ModelMapper modelMapper = new ModelMapper();

    @Test
    public void testAssignMasters() {
        // Arrange
        Long orderId = 1L;
        List<Long> masterIds = Arrays.asList(101L, 102L);

        Order order = new Order();
        order.setId(orderId);

        User master1 = new User();
        master1.setId(101L);
        master1.setUsername("master1");

        User master2 = new User();
        master2.setId(102L);
        master2.setUsername("master2");

        List<User> masters = Arrays.asList(master1, master2);

        when(orderRepository.findById(orderId)).thenReturn(Optional.of(order));
        when(userAccessPort.findAllByIds(masterIds)).thenReturn(masters);

        orderService = new OrderServiceImpl(
                orderRepository,
                userAccessPort,
                modelMapper,
                notificationPort,
                brigadeRepository,
                addressRepository
        );

        // Act
        orderService.assignMasters(orderId, masterIds);

        // Assert
        assertEquals(2, order.getAssignedMasters().size());
        assertEquals("master1", order.getAssignedMasters().get(0).getUsername());
        assertEquals("master2", order.getAssignedMasters().get(1).getUsername());

        verify(orderRepository, times(1)).save(order);
    }
}
