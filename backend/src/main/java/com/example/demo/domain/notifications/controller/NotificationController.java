package com.example.demo.domain.notifications.controller;

import com.example.demo.domain.notifications.dto.NotificationDto;
import com.example.demo.domain.common.config.jwt.JwtTokenUtil;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;
import com.example.demo.domain.notifications.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final JwtTokenUtil jwtTokenUtil;
    private final UserAccessPort userAccessPort;

    @GetMapping
    public ResponseEntity<List<NotificationDto>> getUserNotifications(
            @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        User user = userAccessPort.findByUsername(username);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        List<NotificationDto> notifications = notificationService.getNotificationsForUser(user.getId());
        return ResponseEntity.ok(notifications);
    }
}
