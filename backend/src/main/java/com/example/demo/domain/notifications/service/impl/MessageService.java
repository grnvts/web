package com.example.demo.domain.notifications.service.impl;

import com.example.demo.domain.notifications.model.Message;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;

import java.util.List;

public interface MessageService {
    Message sendMessage(User sender, User recipient, Order order, String content);
  //  List<Message> getMessagesForOrder(Order order);
    List<Message> getMessagesForOrder(Order order, String recipientUsername, String senderUsername);
    List<Message> getDialogMessages(Order order, String user1, String user2);
    List<Message> getAdminUserDialogMessages(Order order, String user);
}
