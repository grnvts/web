package com.example.demo.domain.notifications.service.impl;

import com.example.demo.domain.notifications.model.Message;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.notifications.repo.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageServiceImpl implements MessageService {

    private final MessageRepository messageRepository;

    @Override
    public Message sendMessage(User sender, User recipient, Order order, String content) {
        Message message = new Message();
        message.setSender(sender);
        message.setRecipient(recipient);
        message.setOrder(order);
        message.setContent(content);
        message.setTimestamp(LocalDateTime.now());
        message.setRead(false);
        return messageRepository.save(message);
    }

//    @Override
//    public List<Message> getMessagesForOrder(Order order) {
//        return messageRepository.findByOrder(order);
//    }
@Override
public List<Message> getMessagesForOrder(Order order, String recipientUsername, String senderUsername) {
    return messageRepository.findByOrderAndRecipientOrSender(order, recipientUsername, senderUsername);
}

    public List<Message> getDialogMessages(Order order, String user1, String user2) {
        return messageRepository.findDialogMessages(order, user1, user2);
    }

    @Override
    public List<Message> getAdminUserDialogMessages(Order order, String user) {
        System.out.println("Fetching messages for Order ID: " + order.getId() + ", User: " + user);
        List<Message> messages = messageRepository.findAdminUserDialogMessages(order, user);
        System.out.println("Messages fetched: " + messages.size());
        for (Message message : messages) {
            System.out.println("Message: " + message.getContent() + ", Sender: " + message.getSender().getUsername() + ", Recipient: " + message.getRecipient().getUsername());
        }
        return messages;
    }
}
