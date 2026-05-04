package com.example.demo.domain.notifications.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class ChatDialogSnapshotDto {
    private Long orderId;
    private String dialogUsername;
    private List<MessageDto> messages;
}
