package com.example.demo.domain.notifications.controller;

import com.example.demo.domain.notifications.dto.MessageDto;
import com.example.demo.domain.notifications.model.Message;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.common.config.jwt.JwtUserDetails;
import com.example.demo.domain.notifications.service.MessageService;
import com.example.demo.domain.orders.service.OrderService;
import com.example.demo.domain.users.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
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

    @Operation(summary = "Send a message", description = "Send a message from the authenticated user to a recipient for a specific order")
    @PostMapping
    public ResponseEntity<?> sendMessage(@AuthenticationPrincipal JwtUserDetails user,
                                         @RequestBody MessageDto messageDto) {
        User sender = userService.getUserEntity(user.getUsername());
        User recipient = userService.getUserEntity(messageDto.getRecipientUsername());
        Order order = orderService.getOrderEntity(messageDto.getOrderId());

        Message message = messageService.sendMessage(sender, recipient, order, messageDto.getContent());
        return ResponseEntity.ok(new MessageDto(message));
    }

    @Operation(summary = "Get messages for an order", description = "Retrieve messages for a specific order between a sender and recipient")
    @GetMapping("/{orderId}")
    public List<MessageDto> getMessagesForOrder(
            @AuthenticationPrincipal JwtUserDetails user,
            @PathVariable Long orderId,
            @RequestParam String recipientUsername,
            @RequestParam String senderUsername) {
        Order order = orderService.getOrderEntity(orderId);
        User requester = userService.getUserEntity(user.getUsername());
        return messageService.getMessagesForOrder(requester, order, recipientUsername, senderUsername).stream()
                .map(MessageDto::new)
                .collect(Collectors.toList());
    }

    @Operation(summary = "Get admin-user dialog messages", description = "Retrieve dialog messages between an admin and a user for a specific order")
    @GetMapping("/{orderId}/admin-dialog")
    public List<MessageDto> getAdminUserDialogMessages(@PathVariable Long orderId,
                                                       @RequestParam String user,
                                                       @AuthenticationPrincipal JwtUserDetails currentUser) {
        Order order = orderService.getOrderEntity(orderId);
        User requester = userService.getUserEntity(currentUser.getUsername());
        return messageService.getAdminUserDialogMessages(requester, order, user)
                .stream().map(MessageDto::new).collect(Collectors.toList());
    }

    @Operation(summary = "Get dialog messages", description = "Retrieve dialog messages between two users for a specific order")
    @GetMapping("/{orderId}/dialog")
    public List<MessageDto> getDialogMessages(@PathVariable Long orderId,
                                              @AuthenticationPrincipal JwtUserDetails currentUser,
                                              @RequestParam String user1,
                                              @RequestParam String user2) {
        Order order = orderService.getOrderEntity(orderId);
        User requester = userService.getUserEntity(currentUser.getUsername());
        User dialogUser = userService.getUserEntity(
                requester.getUsername().equals(user1) ? user2 : user1
        );
        return messageService.getDialogMessages(requester, order, dialogUser)
                .stream().map(MessageDto::new).collect(Collectors.toList());
    }
}
