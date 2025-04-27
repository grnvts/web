package com.example.demo.repo;

import com.example.demo.model.Message;
import com.example.demo.model.Order;
import com.example.demo.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findByOrderAndRecipient(Order order, User recipient);
    List<Message> findByOrderAndSender(Order order, User sender);
    List<Message> findByOrder(Order order);
}