package com.example.demo.domain.notifications.service;

import com.example.demo.domain.notifications.model.Message;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;

import java.util.List;

public interface MessageService {
    Message sendMessage(User sender, User recipient, Order order, String content);

    List<Message> getMessagesForOrder(User requester, Order order, String recipientUsername, String senderUsername);

    List<Message> getDialogMessages(User requester, Order order, User dialogUser);

    List<Message> getAdminUserDialogMessages(User requester, Order order, String user);
}
