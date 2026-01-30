package com.example.demo.domain.notifications.service;

import com.example.demo.domain.notifications.model.Notification;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.orders.port.NotificationPort;
import com.example.demo.domain.users.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationAdapter implements NotificationPort {
    private final NotificationService notificationService;

    @Override
    public void notifyOrderStatus(Order order, User user, String message) {
        notificationService.createNotification(order, user, message);
    }
}
