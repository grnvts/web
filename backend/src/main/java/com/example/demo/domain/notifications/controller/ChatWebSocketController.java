package com.example.demo.domain.notifications.controller;

import com.example.demo.domain.notifications.dto.ChatMessageRequestDto;
import com.example.demo.domain.notifications.dto.ChatDialogRequestDto;
import com.example.demo.domain.notifications.dto.ChatDialogSnapshotDto;
import com.example.demo.domain.notifications.dto.MessageDto;
import com.example.demo.domain.notifications.model.Message;
import com.example.demo.domain.notifications.service.MessageService;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.orders.service.OrderService;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final MessageService messageService;
    private final OrderService orderService;
    private final UserService userService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat.dialog")
    public void loadDialog(Authentication authentication, @Payload ChatDialogRequestDto request) {
        if (authentication == null || authentication.getName() == null) {
            throw new RuntimeException("User not authenticated");
        }

        User requester = userService.getUserEntity(authentication.getName());
        User dialogUser = userService.getUserEntity(request.getDialogUsername());
        Order order = orderService.getOrderEntity(request.getOrderId());

        List<MessageDto> messages = messageService.getDialogMessages(requester, order, dialogUser)
                .stream()
                .map(MessageDto::new)
                .collect(Collectors.toList());

        messagingTemplate.convertAndSendToUser(
                requester.getUsername(),
                "/queue/messages.history",
                new ChatDialogSnapshotDto(order.getId(), dialogUser.getUsername(), messages)
        );
    }

    @MessageMapping("/chat.send")
    public void sendMessage(Authentication authentication, @Payload ChatMessageRequestDto request) {
        if (authentication == null || authentication.getName() == null) {
            throw new RuntimeException("User not authenticated");
        }

        User sender = userService.getUserEntity(authentication.getName());
        User recipient = userService.getUserEntity(request.getRecipientUsername());
        Order order = orderService.getOrderEntity(request.getOrderId());

        Message saved = messageService.sendMessage(sender, recipient, order, request.getContent());
        MessageDto payload = new MessageDto(saved);

        messagingTemplate.convertAndSendToUser(
                recipient.getUsername(),
                "/queue/messages",
                payload
        );
        messagingTemplate.convertAndSendToUser(
                sender.getUsername(),
                "/queue/messages",
                payload
        );
    }
}
