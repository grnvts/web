package com.example.demo.service.impl;

import com.example.demo.dto.OrderDto;
import com.example.demo.model.Building;
import com.example.demo.model.Order;
import com.example.demo.model.User;
import com.example.demo.repo.BuildingRepository;
import com.example.demo.repo.OrderRepository;
import com.example.demo.repo.UserRepository;
import com.example.demo.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final BuildingRepository buildingRepository;
    private final ModelMapper mapper;

    @Override
    public OrderDto createOrder(OrderDto dto, String username) {
        User client = userRepository.findUserByUsernameWithStatusOne(username);
        Building building = buildingRepository.findById(dto.getBuildingId())
                .orElseThrow(() -> new RuntimeException("Building not found"));

        Order order = new Order();
        order.setClient(client);
        order.setBuilding(building);
        order.setOrderDetails(dto.getOrderDetails());
        order.setStatus("NEW");

        Order saved = orderRepository.save(order);
        return toDto(saved);
    }

    @Override
    public List<OrderDto> getOrdersForClient(String username) {
        User user = userRepository.findUserByUsernameWithStatusOne(username);
        return orderRepository.findByClient(user).stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public OrderDto getOrderById(Long id, String username) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (!order.getClient().getUsername().equals(username)) {
            throw new RuntimeException("Access denied");
        }

        return toDto(order);
    }

    private OrderDto toDto(Order order) {
        OrderDto dto = new OrderDto();
        dto.setId(order.getId());
        dto.setClientId(order.getClient().getId());
        dto.setClientUsername(order.getClient().getUsername());
        if (order.getBrigadier() != null) {
            dto.setBrigadierId(order.getBrigadier().getId());
            dto.setBrigadierUsername(order.getBrigadier().getUsername());
        }
        dto.setBuildingId(order.getBuilding().getId());
        dto.setOrderDetails(order.getOrderDetails());
        dto.setCreatedDate(order.getCreatedDate());
        dto.setStatus(order.getStatus());
        dto.setPrice(order.getPrice());
        dto.setStartDate(order.getStartDate());
        dto.setEndDate(order.getEndDate());
        return dto;
    }
}
