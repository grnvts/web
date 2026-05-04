package com.example.demo.domain.notifications.port;

import com.example.demo.domain.notifications.model.Notification;

import java.util.Optional;
import java.util.List;

public interface NotificationRepositoryPort {
    List<Notification> findByUserIdOrderByCreatedAtDesc(Long userId);

    Notification save(Notification notification);

    Optional<Notification> findById(Long id);

    long countByUserIdAndReadFalse(Long userId);
}
