package com.example.demo.dto;

import com.example.demo.model.Message;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessageDto {
    private Long id;
    private String senderUsername;
    private String recipientUsername;
    private Long orderId;
    private String content;
    private LocalDateTime timestamp;

    public MessageDto(Message message) {
        this.id = message.getId();
        this.senderUsername = message.getSender().getUsername();
        this.recipientUsername = message.getRecipient().getUsername();
        this.orderId = message.getOrder().getId();
        this.content = message.getContent();
        this.timestamp = message.getTimestamp();
    }
}
