package com.example.demo.domain.notifications.repo;

import com.example.demo.domain.notifications.model.Notification;
import com.example.demo.domain.notifications.port.NotificationRepositoryPort;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long>, NotificationRepositoryPort {
    @Override
    @EntityGraph(attributePaths = {"user", "actorUser", "order", "type"})
    List<Notification> findByUserIdOrderByCreatedAtDesc(Long userId);

    @Override
    long countByUserIdAndReadFalse(Long userId);
}
