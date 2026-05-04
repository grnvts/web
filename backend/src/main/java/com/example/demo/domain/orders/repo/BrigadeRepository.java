package com.example.demo.domain.orders.repo;

import com.example.demo.domain.orders.model.Brigade;
import com.example.demo.domain.orders.port.BrigadeRepositoryPort;
import com.example.demo.domain.users.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BrigadeRepository extends JpaRepository<Brigade, Long>, BrigadeRepositoryPort {
    Optional<Brigade> findByBrigadier(User brigadier);

}
