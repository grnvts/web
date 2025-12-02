package com.example.demo.service.impl;

import com.example.demo.dto.AddressDto;
import com.example.demo.dto.OrderDto;
import com.example.demo.dto.UserDto;
import com.example.demo.error.NotFoundException;
import com.example.demo.model.*;
import com.example.demo.repo.*;
import com.example.demo.service.NotificationService;
import com.example.demo.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.security.access.AccessDeniedException;

import javax.transaction.Transactional;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ModelMapper mapper;
    private final NotificationService notificationService;
    private final BrigadeRepository brigadeRepository;

    @Autowired
    private AddressRepository addressRepository;
    private RoleRepository roleRepository;


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
        Order order = orderRepository.findByIdWithBrigadier(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        // Проверяем, является ли пользователь владельцем заказа, бригадиром или администратором
        boolean isClient = order.getClient().getUsername().equals(username);
        boolean isBrigadier = order.getBrigade() != null && order.getBrigade().getBrigadier() != null && order.getBrigade().getBrigadier().getUsername().equals(username);
        boolean isAdmin = userRepository.findByUsername(username).getRoles().stream()
                .anyMatch(role -> role.getName() == RoleName.ROLE_ADMIN);

        if (!isClient && !isBrigadier && !isAdmin) {
            throw new RuntimeException("Access denied: You do not have permission to view this order");
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
//        dto.setAssignedMasters(
//                order.getAssignedMasters().stream()
//                        .map(UserDto::new)
//                        .collect(Collectors.toList())
//        );



//        if (order.getBrigadier() != null) {
//            dto.setBrigadierId(order.getBrigadier().getId() );
//            dto.setBrigadierUsername(order.getBrigadier().getUsername());
//            dto.setBrigadierName(order.getBrigadier().getName());
//            dto.setBrigadierSurname(order.getBrigadier().getSurname());
//            dto.setBrigadierPatronymic(order.getBrigadier().getPatronymic());
//            dto.setBrigadierPhone(order.getBrigadier().getPhone());
//        }

        // Convert Address entity to AddressDto
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
                .orElseThrow(() -> new RuntimeException("Order not found"));

        User brigadier = userRepository.findByUsername(brigadierUsername);
        if (brigadier == null || brigadier.getRoles().stream().noneMatch(role -> role.getName() == RoleName.ROLE_BRIGADIER)) {
            throw new RuntimeException("Invalid brigadier");
        }

        // Находим бригаду по бригадиру
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));

        // Устанавливаем бригаду в заказ
        order.setBrigade(brigade);

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
                order.getBrigade().setBrigadier(brigadier);
            } else {
                order.getBrigade().setBrigadier(null);
            }
        }

        orderRepository.save(order);
    }

//

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
                        row -> row[0].toString(),         // дата как строка
                        row -> ((Number) row[1]).longValue() // кол-во заказов
                ));
    }
    @Override
    public List<UserDto> getAllBrigadiers() {
        List<User> brigadiers = userRepository.findAll().stream()
                .filter(user -> user.getRoles().stream()
                        .anyMatch(role -> role.getName().name().equals("ROLE_BRIGADIER")))
                .collect(Collectors.toList());

        return brigadiers.stream().map(UserDto::new).collect(Collectors.toList());
    }
   @Override
   @Transactional
   public void updateOrderStatus(Long id, String status, String message) {
       Order order = orderRepository.findById(id)
               .orElseThrow(() -> new RuntimeException("Order not found"));

       User client = order.getClient(); // Получаем клиента заказа

       try {
           OrderStatus orderStatus = OrderStatus.valueOf(status.toUpperCase());
           order.setStatus(orderStatus);
           orderRepository.save(order);

           // Формируем сообщение для уведомления
           String notificationMessage = String.format(
                   "Order #%d status changed to %s. %s",
                   order.getId(),
                   orderStatus.name(),
                   message != null ? message : ""
           );

           // Создаем уведомление
           notificationService.createNotification(order, client, notificationMessage);

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
        User brigadier = userRepository.findUserByUsername(username)
                .orElseThrow(() -> new RuntimeException("Brigadier not found"));
        List<Order> orders = orderRepository.findByBrigadierId(brigadier.getId());
        System.out.println("Brigadier ID: " + brigadier.getId());
        System.out.println("Orders: " + orders);
        return orders.stream()
                .map(order -> mapper.map(order, OrderDto.class))
                .collect(Collectors.toList());

    }

    @Override
    public Order getOrderEntity(Long orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
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
        List<User> masters = userRepository.findAllById(masterIds);
        order.setAssignedMasters(masters);
        orderRepository.save(order);
    }

    @Override
    public List<UserDto> getAssignedMasters(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new NotFoundException());

        String currentUsername;
        try {
            currentUsername = SecurityContextHolder.getContext().getAuthentication().getName();
        } catch (Exception e) {
            throw new AccessDeniedException("Не удалось получить имя пользователя");
        }

        // Проверяем, является ли текущий пользователь админом
        boolean isAdmin = SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("ROLE_ADMIN"));

        // Если не админ, проверяем, является ли пользователь бригадиром этого заказа
        if (!isAdmin) {
            if (order.getBrigade() == null || order.getBrigade().getBrigadier() == null) {
                throw new AccessDeniedException("Order does not have a brigadier assigned");
            }
            if (!order.getBrigade().getBrigadier().getUsername().equals(currentUsername)) {
                throw new AccessDeniedException("You don't have permission to view masters for this order");
            }
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
    public Order addExpense(Long orderId, Double amount) {
        if (amount == null || amount <= 0) {
            throw new IllegalArgumentException("Некорректная сумма расходов");
        }

        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Заказ не найден"));

        order.setPrice(order.getPrice().add(BigDecimal.valueOf(amount)));
        orderRepository.save(order);

        return order;
    }


}
