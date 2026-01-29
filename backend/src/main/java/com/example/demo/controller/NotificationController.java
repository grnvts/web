package com.example.demo.controller;

import com.example.demo.dto.NotificationDto;
import com.example.demo.jwt.config.JwtTokenUtil;
import com.example.demo.model.User;
import com.example.demo.repo.UserRepository;
import com.example.demo.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final JwtTokenUtil jwtTokenUtil;
    private final UserRepository userRepository; // Добавляем репозиторий для поиска пользователя

    @GetMapping
    public ResponseEntity<List<NotificationDto>> getUserNotifications(
            @RequestHeader("Authorization") String authHeader) {
        String username = jwtTokenUtil.getUsernameFromToken(authHeader.replace("Bearer ", ""));
        User user = userRepository.findUserByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        List<NotificationDto> notifications = notificationService.getNotificationsForUser(user.getId());
        return ResponseEntity.ok(notifications);
    }
}
