package com.example.demo.controller;

import com.example.demo.dto.MessageDto;
import com.example.demo.model.Message;
import com.example.demo.model.Order;
import com.example.demo.model.User;
import com.example.demo.service.MessageService;
import com.example.demo.service.OrderService;
import com.example.demo.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/messages")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;
    private final OrderService orderService;
    private final UserService userService;

    @PostMapping
    public ResponseEntity<?> sendMessage(@RequestBody MessageDto messageDto) {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        User sender = userService.getUserEntity(username);
        User recipient = userService.getUserEntity(messageDto.getRecipientUsername());
        Order order = orderService.getOrderEntity(messageDto.getOrderId());

        // Передаем все необходимые параметры
        Message message = messageService.sendMessage(sender, recipient, order, messageDto.getContent());
        return ResponseEntity.ok(new MessageDto(message));
    }

    @GetMapping("/{orderId}")
    public List<MessageDto> getMessagesForOrder(
            @PathVariable Long orderId,
            @RequestParam String recipientUsername,
            @RequestParam String senderUsername) {
        Order order = orderService.getOrderEntity(orderId);
        return messageService.getMessagesForOrder(order, recipientUsername, senderUsername).stream()
                .map(MessageDto::new)
                .collect(Collectors.toList());
    }

    @GetMapping("/{orderId}/dialog")
    public List<MessageDto> getDialogMessages(@PathVariable Long orderId,
                                              @RequestParam String user1,
                                              @RequestParam String user2) {
        Order order = orderService.getOrderEntity(orderId);
        return messageService.getDialogMessages(order, user1, user2)
                .stream().map(MessageDto::new).collect(Collectors.toList());
    }

    @GetMapping("/{orderId}/admin-dialog")
    public List<MessageDto> getAdminUserDialogMessages(@PathVariable Long orderId,
                                                       @RequestParam String user) {
        Order order = orderService.getOrderEntity(orderId);
        // user — это username пользователя (не админа!)
        return messageService.getAdminUserDialogMessages(order, user, "admin")
                .stream().map(MessageDto::new).collect(Collectors.toList());
    }
}