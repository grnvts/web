package com.example.demo.domain.orders.port;

import com.example.demo.domain.users.model.User;
import com.example.demo.domain.orders.model.Order;

public interface NotificationPort {
    void notifyOrderStatus(Order order, User user, String message);
}
