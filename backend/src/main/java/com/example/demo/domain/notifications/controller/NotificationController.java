package com.example.demo.domain.notifications.controller;

import com.example.demo.domain.notifications.dto.NotificationDto;
import com.example.demo.domain.common.config.jwt.JwtUserDetails;
import com.example.demo.domain.notifications.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<List<NotificationDto>> getUserNotifications(
            @AuthenticationPrincipal JwtUserDetails user) {
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        List<NotificationDto> notifications = notificationService.getNotificationsForUser(user.getId());
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Long> getUnreadCount(@AuthenticationPrincipal JwtUserDetails user) {
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        return ResponseEntity.ok(notificationService.getUnreadCount(user.getId()));
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable Long id,
            @AuthenticationPrincipal JwtUserDetails user) {
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        notificationService.markAsRead(id, user.getId());
        return ResponseEntity.noContent().build();
    }
}
