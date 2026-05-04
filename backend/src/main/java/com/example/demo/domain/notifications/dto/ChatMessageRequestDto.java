package com.example.demo.domain.notifications.dto;

import lombok.Data;

@Data
public class ChatMessageRequestDto {
    private Long orderId;
    private String recipientUsername;
    private String content;
}
