package com.example.demo.service.impl;

import com.example.demo.model.Message;
import com.example.demo.model.Order;
import com.example.demo.model.User;
import com.example.demo.repo.MessageRepository;
import com.example.demo.service.MessageService;
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

    public List<Message> getAdminUserDialogMessages(Order order, String user, String admin) {
        return messageRepository.findAdminUserDialogMessages(order, user, user, admin);
    }
}