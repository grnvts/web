package com.example.demo.domain.notifications.service.impl;

import com.example.demo.domain.common.error.BadRequestException;
import com.example.demo.domain.common.error.NotFoundException;
import com.example.demo.domain.notifications.dto.NotificationDto;
import com.example.demo.domain.notifications.model.Notification;
import com.example.demo.domain.notifications.model.NotificationType;
import com.example.demo.domain.notifications.port.NotificationRepositoryPort;
import com.example.demo.domain.notifications.repo.NotificationTypeRepository;
import com.example.demo.domain.notifications.service.NotificationService;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepositoryPort notificationRepository;
    private final NotificationTypeRepository notificationTypeRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    public List<NotificationDto> getNotificationsForUser(Long userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toDto)
                .toList();
    }

    @Override
    public void createNotification(Order order, User user, String message) {
        NotificationType type = notificationTypeRepository.findByCode("ORDER_STATUS")
                .orElse(null);

        Notification notification = new Notification();
        notification.setOrder(order);
        notification.setUser(user);
        notification.setType(type);
        notification.setTitle("Order status updated");
        notification.setMessage(message != null ? message : "-");
        Notification saved = notificationRepository.save(notification);
        pushNotification(saved);
    }

    @Override
    @Transactional
    public void markAsRead(Long notificationId, Long userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(NotFoundException::new);

        if (notification.getUser() == null || !notification.getUser().getId().equals(userId)) {
            throw new BadRequestException("Notification does not belong to the current user");
        }

        notification.setRead(true);
        notification.setReadAt(java.time.LocalDateTime.now());
        notificationRepository.save(notification);
    }

    @Override
    public long getUnreadCount(Long userId) {
        return notificationRepository.countByUserIdAndReadFalse(userId);
    }

    private NotificationDto toDto(Notification notification) {
        return NotificationDto.builder()
                .id(notification.getId())
                .userId(notification.getUser() != null ? notification.getUser().getId() : null)
                .actorUserId(notification.getActorUser() != null ? notification.getActorUser().getId() : null)
                .orderId(notification.getOrder() != null ? notification.getOrder().getId() : null)
                .typeCode(notification.getType() != null ? notification.getType().getCode() : null)
                .typeName(notification.getType() != null ? notification.getType().getName() : null)
                .title(notification.getTitle())
                .message(notification.getMessage())
                .read(notification.isRead())
                .readAt(notification.getReadAt())
                .createdAt(notification.getCreatedAt())
                .build();
    }

    private void pushNotification(Notification notification) {
        if (notification.getUser() == null) {
            return;
        }
        messagingTemplate.convertAndSendToUser(
                notification.getUser().getUsername(),
                "/queue/notifications",
                toDto(notification)
        );
    }
}
