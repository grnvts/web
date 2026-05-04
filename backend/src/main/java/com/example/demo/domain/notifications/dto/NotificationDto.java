package com.example.demo.domain.notifications.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDto {
    private Long id;
    private Long userId;
    private Long actorUserId;
    private Long orderId;
    private String typeCode;
    private String typeName;
    private String title;
    private String message;
    private boolean read;
    private LocalDateTime readAt;
    private LocalDateTime createdAt;
}
