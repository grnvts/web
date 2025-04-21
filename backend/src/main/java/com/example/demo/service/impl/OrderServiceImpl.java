package com.example.demo.service.impl;

import com.example.demo.dto.AddressDto;
import com.example.demo.dto.OrderDto;
import com.example.demo.model.*;
import com.example.demo.repo.AddressRepository;
import com.example.demo.repo.BuildingRepository;
import com.example.demo.repo.OrderRepository;
import com.example.demo.repo.UserRepository;
import com.example.demo.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final BuildingRepository buildingRepository;
    private final ModelMapper mapper;

    @Autowired
    private AddressRepository addressRepository;

    @Override
    @Transactional
    public OrderDto createOrder(OrderDto dto, String username) {
        User client = userRepository.findUserByUsernameWithStatusOne(username);
        AddressDto addressDto = dto.getAddress();

        Address address = new Address();
        address.setCity(addressDto.getCity());
        address.setStreet(addressDto.getStreet());
        address.setBuildingNo(addressDto.getBuildingNo());
        address.setApartmentNo(addressDto.getApartmentNo());
        address.setUser(client);

        address = addressRepository.save(address);

        Order order = new Order();
        order.setClient(client);
        order.setAddress(address);
        order.setOrderDetails(dto.getOrderDetails());
        order.setStatus(OrderStatus.CREATED);
        order.setServiceType(dto.getServiceType());
        order.setStartDate(dto.getStartDate());

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

        // Проверяем, является ли пользователь владельцем заказа или администратором
        if (!order.getClient().getUsername().equals(username) &&
                !userRepository.findByUsername(username).getRoles().stream()
                        .anyMatch(role -> role.getName().equals(RoleName.ROLE_ADMIN))) {
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

        // Convert Address entity to AddressDto
        Address address = order.getAddress();
        if (address != null) {
            AddressDto addressDto = new AddressDto();
            addressDto.setId(address.getId());
            addressDto.setStreet(address.getStreet());
            addressDto.setCity(address.getCity());
            addressDto.setBuildingNo(address.getBuildingNo());
            addressDto.setApartmentNo(address.getApartmentNo());
            dto.setAddress(addressDto);
        }

        dto.setOrderDetails(order.getOrderDetails());
        dto.setCreatedDate(order.getCreatedDate());
        dto.setStatus(order.getStatus());
        dto.setPrice(order.getPrice());
        dto.setStartDate(order.getStartDate());
        dto.setEndDate(order.getEndDate());
        dto.setServiceType(order.getServiceType());

        return dto;
    }
    @Override
    public void assignBrigadier(Long orderId, String brigadierUsername) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        User brigadier = userRepository.findByUsername(brigadierUsername);
        if (brigadier == null || brigadier.getRoles().stream().noneMatch(role -> role.getName() == RoleName.ROLE_BRIGADIER)) {
            throw new RuntimeException("Invalid brigadier");
        }

        order.setBrigadier(brigadier);
        orderRepository.save(order);
    }

    @Override
    @Transactional
    public void updateOrder(Long id, OrderDto updatedOrder) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        // Обновляем тип услуги
        order.setServiceType(updatedOrder.getServiceType());

        // Обновляем детали заказа
        order.setOrderDetails(updatedOrder.getOrderDetails());

        // Обновляем статус
        order.setStatus(updatedOrder.getStatus());

        // Обновляем дату начала и окончания
        if (updatedOrder.getStartDate() != null) {
            order.setStartDate(updatedOrder.getStartDate());
        }
        if (updatedOrder.getEndDate() != null) {
            order.setEndDate(updatedOrder.getEndDate());
        }

        // Обновляем цену
        if (updatedOrder.getPrice() != null) {
            order.setPrice(updatedOrder.getPrice());
        }

        // Обновляем адрес
        if (updatedOrder.getAddress() != null) {
            Address address = order.getAddress();
            AddressDto addressDto = updatedOrder.getAddress();
            address.setCity(addressDto.getCity());
            address.setStreet(addressDto.getStreet());
            address.setBuildingNo(addressDto.getBuildingNo());
            address.setApartmentNo(addressDto.getApartmentNo());
            addressRepository.save(address);
        }

        // Обновляем бригадира
        if (updatedOrder.getBrigadierUsername() != null) {
            User brigadier = userRepository.findByUsername(updatedOrder.getBrigadierUsername());
            if (brigadier != null) {
                order.setBrigadier(brigadier);
            } else {
                order.setBrigadier(null);
            }
        }

        orderRepository.save(order);
    }

    @Override
    public void updateOrderStatus(Long id, String status) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        try {
            OrderStatus orderStatus = OrderStatus.valueOf(status.toUpperCase());
            order.setStatus(orderStatus);
            orderRepository.save(order);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid order status: " + status);
        }
    }

    @Override
    public List<OrderDto> getAllOrders() {
        return orderRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }
}
