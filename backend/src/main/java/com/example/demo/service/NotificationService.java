package com.example.demo.service;

import com.example.demo.dto.NotificationDto;
import com.example.demo.model.Order;
import com.example.demo.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

public interface NotificationService {
    public void createNotification(Order order, User user, String message);
    List<NotificationDto> getNotificationsForUser(Long userId);


}