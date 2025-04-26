package com.example.demo.service.impl;

import com.example.demo.dto.NotificationDto;
import com.example.demo.model.Notification;
import com.example.demo.model.Order;
import com.example.demo.model.User;
import com.example.demo.repo.NotificationRepository;
import com.example.demo.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final ModelMapper modelMapper;

    public List<NotificationDto> getNotificationsForUser(Long userId) {
        List<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return notifications.stream()
                .map(notification -> modelMapper.map(notification, NotificationDto.class))
                .collect(Collectors.toList());
    }
    public void createNotification(Order order, User user, String message) {
        Notification notification = new Notification();
        notification.setOrder(order);
        notification.setUser(user);
        notification.setMessage(message);
        notificationRepository.save(notification);
    }
}