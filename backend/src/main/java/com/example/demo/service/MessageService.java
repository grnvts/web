package com.example.demo.service;

import com.example.demo.model.Message;
import com.example.demo.model.Order;
import com.example.demo.model.User;

import java.util.List;

public interface MessageService {
    Message sendMessage(User sender, User recipient, Order order, String content);
    List<Message> getMessagesForOrder(Order order);
}