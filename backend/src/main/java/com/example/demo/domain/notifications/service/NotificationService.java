package com.example.demo.domain.notifications.service;

import com.example.demo.domain.notifications.dto.NotificationDto;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;

import java.util.List;

public interface NotificationService {
    public void createNotification(Order order, User user, String message);
    List<NotificationDto> getNotificationsForUser(Long userId);


}
