package com.example.demo.domain.notifications.service.impl;

import com.example.demo.domain.common.error.BadRequestException;
import com.example.demo.domain.common.error.ForbiddenException;
import com.example.demo.domain.notifications.model.Notification;
import com.example.demo.domain.notifications.model.NotificationType;
import com.example.demo.domain.notifications.model.Message;
import com.example.demo.domain.notifications.port.NotificationRepositoryPort;
import com.example.demo.domain.notifications.repo.NotificationTypeRepository;
import com.example.demo.domain.notifications.service.MessageService;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.model.RoleName;
import com.example.demo.domain.notifications.port.MessageRepositoryPort;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class MessageServiceImpl implements MessageService {

    private final MessageRepositoryPort messageRepository;
    private final NotificationRepositoryPort notificationRepository;
    private final NotificationTypeRepository notificationTypeRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    public Message sendMessage(User sender, User recipient, Order order, String content) {
        if (content == null || content.trim().isEmpty()) {
            throw new BadRequestException("Message content is required");
        }
        validateDialogAccess(sender, recipient, order);

        Message message = new Message();
        message.setSender(sender);
        message.setRecipient(recipient);
        message.setOrder(order);
        message.setContent(content.trim());
        message.setTimestamp(LocalDateTime.now());
        message.setRead(false);
        Message saved = messageRepository.save(message);

        NotificationType type = notificationTypeRepository.findByCode("CHAT_MESSAGE")
                .orElse(null);

        Notification notification = new Notification();
        notification.setUser(recipient);
        notification.setActorUser(sender);
        notification.setOrder(order);
        notification.setType(type);
        notification.setTitle("New message");
        notification.setMessage(saved.getContent());
        Notification savedNotification = notificationRepository.save(notification);

        messagingTemplate.convertAndSendToUser(
                recipient.getUsername(),
                "/queue/notifications",
                com.example.demo.domain.notifications.dto.NotificationDto.builder()
                        .id(savedNotification.getId())
                        .userId(recipient.getId())
                        .actorUserId(sender.getId())
                        .orderId(order.getId())
                        .typeCode(type != null ? type.getCode() : null)
                        .typeName(type != null ? type.getName() : null)
                        .title(savedNotification.getTitle())
                        .message(savedNotification.getMessage())
                        .read(savedNotification.isRead())
                        .readAt(savedNotification.getReadAt())
                        .createdAt(savedNotification.getCreatedAt())
                        .build()
        );

        return saved;
    }

//    @Override
//    public List<Message> getMessagesForOrder(Order order) {
//        return messageRepository.findByOrder(order);
//    }
    @Override
    public List<Message> getMessagesForOrder(
            User requester,
            Order order,
            String recipientUsername,
            String senderUsername
    ) {
        if (!Objects.equals(requester.getUsername(), recipientUsername)
                && !Objects.equals(requester.getUsername(), senderUsername)
                && !isAdmin(requester)) {
            throw new ForbiddenException("You are not allowed to view this dialog");
        }

        User otherUserUsernameOwner = Objects.equals(requester.getUsername(), senderUsername)
                ? findOrderParticipant(order, recipientUsername)
                : findOrderParticipant(order, senderUsername);
        validateDialogAccess(requester, otherUserUsernameOwner, order);

        return messageRepository.findByOrderAndRecipientOrSender(
                order,
                recipientUsername,
                senderUsername
        );
    }

    @Override
    public List<Message> getDialogMessages(User requester, Order order, User dialogUser) {
        validateDialogAccess(requester, dialogUser, order);
        return messageRepository.findDialogMessages(
                order,
                requester.getUsername(),
                dialogUser.getUsername()
        );
    }

    @Override
    public List<Message> getAdminUserDialogMessages(User requester, Order order, String user) {
        User dialogUser = findOrderParticipant(order, user);
        validateDialogAccess(requester, dialogUser, order);
        return messageRepository.findAdminUserDialogMessages(order, user);
    }

    private void validateDialogAccess(User requester, User dialogUser, Order order) {
        if (requester == null || dialogUser == null || order == null) {
            throw new BadRequestException("Chat participants and order are required");
        }
        if (Objects.equals(requester.getId(), dialogUser.getId())) {
            throw new BadRequestException("Cannot open a dialog with yourself");
        }
        if (!isAllowedParticipant(requester, order)) {
            throw new ForbiddenException("You are not allowed to access this order chat");
        }
        if (!isAllowedParticipant(dialogUser, order)) {
            throw new ForbiddenException("Recipient is not allowed in this order chat");
        }
        if (!isAllowedPair(requester, dialogUser, order)) {
            throw new ForbiddenException("This chat pair is not allowed for the order");
        }
    }

    private User findOrderParticipant(Order order, String username) {
        if (username == null || username.isBlank()) {
            throw new BadRequestException("Dialog username is required");
        }
        if (order.getClient() != null && username.equals(order.getClient().getUsername())) {
            return order.getClient();
        }
        if (order.getBrigade() != null
                && order.getBrigade().getBrigadier() != null
                && username.equals(order.getBrigade().getBrigadier().getUsername())) {
            return order.getBrigade().getBrigadier();
        }
        if (order.getAssignedMasters() != null) {
            for (User master : order.getAssignedMasters()) {
                if (username.equals(master.getUsername())) {
                    return master;
                }
            }
        }
        throw new ForbiddenException("User is not a participant of this order");
    }

    private boolean isAllowedParticipant(User user, Order order) {
        return isAdmin(user)
                || isClient(user, order)
                || isBrigadier(user, order)
                || isAssignedMaster(user, order);
    }

    private boolean isAllowedPair(User first, User second, Order order) {
        if (isAdmin(first)) {
            return !isAdmin(second) && isAllowedParticipant(second, order);
        }
        if (isAdmin(second)) {
            return !isAdmin(first) && isAllowedParticipant(first, order);
        }

        boolean firstIsClient = isClient(first, order);
        boolean secondIsClient = isClient(second, order);
        boolean firstIsWorker = isBrigadier(first, order) || isAssignedMaster(first, order);
        boolean secondIsWorker = isBrigadier(second, order) || isAssignedMaster(second, order);

        return (firstIsClient && secondIsWorker) || (secondIsClient && firstIsWorker);
    }

    private boolean isClient(User user, Order order) {
        return order.getClient() != null && Objects.equals(order.getClient().getId(), user.getId());
    }

    private boolean isBrigadier(User user, Order order) {
        return order.getBrigade() != null
                && order.getBrigade().getBrigadier() != null
                && Objects.equals(order.getBrigade().getBrigadier().getId(), user.getId());
    }

    private boolean isAssignedMaster(User user, Order order) {
        return order.getAssignedMasters() != null
                && order.getAssignedMasters().stream()
                .anyMatch(master -> Objects.equals(master.getId(), user.getId()));
    }

    private boolean isAdmin(User user) {
        return user.getRoles() != null
                && user.getRoles().stream()
                .anyMatch(role -> role.getName() == RoleName.ROLE_ADMIN);
    }
}
