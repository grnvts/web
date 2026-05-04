package com.example.demo.domain.orders.service.impl;

import com.example.demo.domain.common.error.BadRequestException;
import com.example.demo.domain.common.error.ForbiddenException;
import com.example.demo.domain.common.error.NotFoundException;
import com.example.demo.domain.orders.dto.AddressDto;
import com.example.demo.domain.orders.dto.OrderDto;
import com.example.demo.domain.orders.model.Address;
import com.example.demo.domain.orders.model.Brigade;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.orders.model.OrderStatus;
import com.example.demo.domain.orders.port.AddressRepositoryPort;
import com.example.demo.domain.orders.port.BrigadeRepositoryPort;
import com.example.demo.domain.orders.port.NotificationPort;
import com.example.demo.domain.orders.port.OrderRepositoryPort;
import com.example.demo.domain.orders.service.OrderService;
import com.example.demo.domain.users.dto.UserDto;
import com.example.demo.domain.users.model.RoleName;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepositoryPort orderRepository;
    private final UserAccessPort userAccessPort;
    private final ModelMapper mapper;
    private final NotificationPort notificationPort;
    private final BrigadeRepositoryPort brigadeRepository;
    private final AddressRepositoryPort addressRepository;

    @Override
    @Transactional
    public OrderDto createOrder(OrderDto dto, String username) {
        User client = userAccessPort.findActiveByUsername(username);
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
        User user = userAccessPort.findActiveByUsername(username);
        return orderRepository.findByClient(user).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public OrderDto getOrderById(Long id, String username) {
        Order order = orderRepository.findByIdWithBrigadier(id)
                .orElseThrow(NotFoundException::new);

        boolean isClient = order.getClient().getUsername().equals(username);
        boolean isBrigadier = order.getBrigade() != null
                && order.getBrigade().getBrigadier() != null
                && order.getBrigade().getBrigadier().getUsername().equals(username);
        User requester = userAccessPort.findByUsername(username);
        if (requester == null) {
            throw new NotFoundException();
        }
        boolean isAdmin = hasRole(requester, RoleName.ROLE_ADMIN);

        if (!isClient && !isBrigadier && !isAdmin) {
            throw new ForbiddenException("Access denied: You do not have permission to view this order");
        }

        return toDto(order);
    }

    private OrderDto toDto(Order order) {
        OrderDto dto = new OrderDto();
        dto.setId(order.getId());
        dto.setClientId(order.getClient().getId());
        dto.setClientUsername(order.getClient().getUsername());
        dto.setClientName(order.getClient().getName());
        dto.setClientSurname(order.getClient().getSurname());
        dto.setClientPatronymic(order.getClient().getPatronymic());
        dto.setClientPhone(order.getClient().getPhone());

        if (order.getBrigade() != null) {
            dto.setBrigadeId(order.getBrigade().getId());
            dto.setBrigadeNumber(order.getBrigade().getNumber());
            if (order.getBrigade().getBrigadier() != null) {
                dto.setBrigadierUsername(order.getBrigade().getBrigadier().getUsername());
                dto.setBrigadierName(order.getBrigade().getBrigadier().getName());
                dto.setBrigadierSurname(order.getBrigade().getBrigadier().getSurname());
                dto.setBrigadierPatronymic(order.getBrigade().getBrigadier().getPatronymic());
                dto.setBrigadierPhone(order.getBrigade().getBrigadier().getPhone());
                dto.setBrigadierId(order.getBrigade().getBrigadier().getId());
            }
        }

        Address address = order.getAddress();
        if (address != null) {
            AddressDto addressDto = new AddressDto(order.getAddress());
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
                .orElseThrow(NotFoundException::new);

        User brigadier = userAccessPort.findByUsername(brigadierUsername);
        if (brigadier == null || !hasRole(brigadier, RoleName.ROLE_BRIGADIER)) {
            throw new BadRequestException("Invalid brigadier");
        }

        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(NotFoundException::new);

        order.setBrigade(brigade);
        orderRepository.save(order);
    }

    @Override
    @Transactional
    public void updateOrder(Long id, OrderDto updatedOrder) {
        Order order = orderRepository.findById(id)
                .orElseThrow(NotFoundException::new);

        order.setServiceType(updatedOrder.getServiceType());
        order.setOrderDetails(updatedOrder.getOrderDetails());
        order.setStatus(updatedOrder.getStatus());

        if (updatedOrder.getStartDate() != null) {
            order.setStartDate(updatedOrder.getStartDate());
        }
        if (updatedOrder.getEndDate() != null) {
            order.setEndDate(updatedOrder.getEndDate());
        }
        if (updatedOrder.getPrice() != null) {
            order.setPrice(updatedOrder.getPrice());
        }

        if (updatedOrder.getAddress() != null) {
            Address address = order.getAddress();
            AddressDto addressDto = updatedOrder.getAddress();
            address.setCity(addressDto.getCity());
            address.setStreet(addressDto.getStreet());
            address.setBuildingNo(addressDto.getBuildingNo());
            address.setApartmentNo(addressDto.getApartmentNo());
            addressRepository.save(address);
        }

        if (updatedOrder.getBrigadierUsername() != null) {
            User brigadier = userAccessPort.findByUsername(updatedOrder.getBrigadierUsername());
            if (brigadier != null) {
                if (order.getBrigade() == null) {
                    Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                            .orElseThrow(NotFoundException::new);
                    order.setBrigade(brigade);
                } else {
                    order.getBrigade().setBrigadier(brigadier);
                }
            } else if (order.getBrigade() != null) {
                order.getBrigade().setBrigadier(null);
            }
        }

        orderRepository.save(order);
    }

    @Override
    public List<OrderDto> getAllOrders() {
        return orderRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public Map<String, Long> getOrderCountPerDay(String username, LocalDate start, LocalDate end) {
        return orderRepository.countOrdersByBrigadierPerDay(username, start, end)
                .stream()
                .map(row -> (Object[]) row)
                .collect(Collectors.toMap(
                        row -> row[0].toString(),
                        row -> ((Number) row[1]).longValue()
                ));
    }

    @Override
    public List<UserDto> getAllBrigadiers() {
        return userAccessPort.findAllByRole(RoleName.ROLE_BRIGADIER).stream()
                .map(UserDto::new)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void updateOrderStatus(Long id, String username, String status, String message) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        User requester = userAccessPort.findByUsername(username);
        if (requester == null) {
            throw new ForbiddenException("Unknown requester");
        }

        try {
            OrderStatus orderStatus = OrderStatus.valueOf(status.toUpperCase());
            validateStatusUpdatePermission(order, requester, orderStatus);
            order.setStatus(orderStatus);
            orderRepository.save(order);

            String notificationMessage = String.format(
                    "Order #%d status changed to %s. %s",
                    order.getId(),
                    orderStatus.name(),
                    message != null ? message : ""
            );
            notificationPort.notifyOrderStatus(order, order.getClient(), notificationMessage);
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid order status: " + status);
        }
    }

    @Override
    public List<OrderDto> getActiveOrdersForBrigadier(String username) {
        LocalDate currentDate = LocalDate.now();
        List<Order> orders = orderRepository.findActiveOrdersForBrigadier(username, currentDate);
        return orders.stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<OrderDto> getOrdersForBrigadier(String username) {
        User brigadier = userAccessPort.findByUsername(username);
        if (brigadier == null) {
            throw new NotFoundException();
        }
        return orderRepository.findByBrigadierId(brigadier.getId()).stream()
                .map(order -> mapper.map(order, OrderDto.class))
                .collect(Collectors.toList());
    }

    @Override
    public Order getOrderEntity(Long orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(NotFoundException::new);
    }

    @Override
    public List<UserDto> getBrigadeMasters(Long brigadeId) {
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        return brigade.getMasters().stream().map(UserDto::new).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void assignMasters(Long orderId, List<Long> masterIds) {
        Order order = orderRepository.findById(orderId).orElseThrow();
        List<User> masters = userAccessPort.findAllByIds(masterIds);
        order.setAssignedMasters(masters);
        orderRepository.save(order);
    }

    @Override
    public List<UserDto> getAssignedMasters(Long orderId, String username) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(NotFoundException::new);
        User requester = userAccessPort.findByUsername(username);
        if (requester == null) {
            throw new ForbiddenException("Unknown requester");
        }

        boolean isAdmin = hasRole(requester, RoleName.ROLE_ADMIN);
        boolean isBrigadier = order.getBrigade() != null
                && order.getBrigade().getBrigadier() != null
                && order.getBrigade().getBrigadier().getId() != null
                && order.getBrigade().getBrigadier().getId().equals(requester.getId());
        boolean isClientOwner = order.getClient() != null
                && order.getClient().getId() != null
                && order.getClient().getId().equals(requester.getId());
        if (!isAdmin && !isBrigadier && !isClientOwner) {
            throw new ForbiddenException("You are not allowed to view assigned masters for this order");
        }

        return order.getAssignedMasters().stream()
                .map(this::mapToUserDto)
                .collect(Collectors.toList());
    }

    private UserDto mapToUserDto(User user) {
        UserDto userDto = new UserDto();
        userDto.setId(user.getId());
        userDto.setUsername(user.getUsername());
        userDto.setName(user.getName());
        userDto.setSurname(user.getSurname());
        userDto.setPatronymic(user.getPatronymic());
        userDto.setPhone(user.getPhone());
        return userDto;
    }

    @Override
    @Transactional
    public Order addExpense(Long orderId, String username, Double amount) {
        if (amount == null || amount <= 0) {
            throw new BadRequestException("Некорректная сумма расходов");
        }

        Order order = orderRepository.findById(orderId)
                .orElseThrow(NotFoundException::new);
        User requester = userAccessPort.findByUsername(username);
        if (requester == null) {
            throw new ForbiddenException("Unknown requester");
        }
        validateExpensePermission(order, requester);

        BigDecimal currentPrice = order.getPrice() != null ? order.getPrice() : BigDecimal.ZERO;
        order.setPrice(currentPrice.add(BigDecimal.valueOf(amount)));
        orderRepository.save(order);

        return order;
    }

    private void validateStatusUpdatePermission(Order order, User requester, OrderStatus targetStatus) {
        if (hasRole(requester, RoleName.ROLE_ADMIN)) {
            return;
        }

        boolean isClientOwner = order.getClient() != null
                && order.getClient().getId() != null
                && order.getClient().getId().equals(requester.getId());
        if (isClientOwner) {
            if (order.getStatus() != OrderStatus.COMPLETED) {
                throw new ForbiddenException("Client can only approve or reject completed work");
            }
            if (Set.of(OrderStatus.APPROVED, OrderStatus.REJECTED).contains(targetStatus)) {
                return;
            }
            throw new ForbiddenException("Client can only approve or reject completed work");
        }

        boolean isAssignedBrigadier = order.getBrigade() != null
                && order.getBrigade().getBrigadier() != null
                && order.getBrigade().getBrigadier().getId() != null
                && order.getBrigade().getBrigadier().getId().equals(requester.getId());
        if (isAssignedBrigadier) {
            if (Set.of(OrderStatus.IN_PROGRESS, OrderStatus.COMPLETED).contains(targetStatus)) {
                return;
            }
            throw new ForbiddenException("Brigadier can only start or complete assigned orders");
        }

        throw new ForbiddenException("You are not allowed to update this order status");
    }

    private void validateExpensePermission(Order order, User requester) {
        if (hasRole(requester, RoleName.ROLE_ADMIN)) {
            return;
        }

        boolean isAssignedBrigadier = order.getBrigade() != null
                && order.getBrigade().getBrigadier() != null
                && order.getBrigade().getBrigadier().getId() != null
                && order.getBrigade().getBrigadier().getId().equals(requester.getId());
        if (!isAssignedBrigadier) {
            throw new ForbiddenException("Only admin or assigned brigadier can add expenses");
        }
    }

    private boolean hasRole(User user, RoleName roleName) {
        return user.getRoles().stream().anyMatch(role -> role.getName() == roleName);
    }
}
