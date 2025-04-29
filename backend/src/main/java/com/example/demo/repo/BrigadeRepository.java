package com.example.demo.repo;

import com.example.demo.model.Brigade;
import com.example.demo.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BrigadeRepository extends JpaRepository<Brigade, Long> {
    Optional<Brigade> findByBrigadier(User brigadier);

}