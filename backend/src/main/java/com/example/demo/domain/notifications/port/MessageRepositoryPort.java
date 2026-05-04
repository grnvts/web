package com.example.demo.domain.notifications.port;

import com.example.demo.domain.notifications.model.Message;
import com.example.demo.domain.orders.model.Order;

import java.util.List;

public interface MessageRepositoryPort {
    Message save(Message message);

    List<Message> findByOrderAndRecipientOrSender(
            Order order,
            String recipientUsername,
            String senderUsername
    );

    List<Message> findDialogMessages(Order order, String user1, String user2);

    List<Message> findAdminUserDialogMessages(Order order, String user);
}
