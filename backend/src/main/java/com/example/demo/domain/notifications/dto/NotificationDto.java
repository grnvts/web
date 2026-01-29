package com.example.demo.domain.notifications.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDto {
    private String message;
    private Date orderDate;
    private Date createdAt;
}
