package com.example.demo.domain.notifications.model;

import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;
import lombok.Data;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Data
@Entity
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private User sender;

    @ManyToOne
    private User recipient;

    @ManyToOne
    private Order order;

    private String content;

    private LocalDateTime timestamp;

    private boolean isRead;
}
