package com.example.demo.domain.orders.port;

import com.example.demo.domain.orders.model.Brigade;
import com.example.demo.domain.users.model.User;

import java.util.List;
import java.util.Optional;

public interface BrigadeRepositoryPort {
    Optional<Brigade> findById(Long id);

    Optional<Brigade> findByBrigadier(User brigadier);

    List<Brigade> findAll();

    Brigade save(Brigade brigade);
}
