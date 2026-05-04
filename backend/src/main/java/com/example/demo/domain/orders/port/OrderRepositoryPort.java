package com.example.demo.domain.orders.port;

import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface OrderRepositoryPort {
    Order save(Order order);

    List<Order> findByClient(User client);

    Optional<Order> findById(Long id);

    Optional<Order> findByIdWithBrigadier(Long id);

    List<Order> findAll();

    List<Object[]> countOrdersByBrigadierPerDay(
            String username,
            LocalDate start,
            LocalDate end
    );

    List<Order> findByBrigadierId(Long brigadierId);

    List<Order> findActiveOrdersForBrigadier(String username, LocalDate currentDate);
}
