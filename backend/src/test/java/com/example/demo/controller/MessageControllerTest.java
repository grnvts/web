package com.example.demo.controller;

import com.example.demo.dto.MessageDto;
import com.example.demo.model.Message;
import com.example.demo.model.Order;
import com.example.demo.model.User;
import com.example.demo.service.MessageService;
import com.example.demo.service.OrderService;
import com.example.demo.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class MessageControllerTest {

    @Mock
    private MessageService messageService;

    @Mock
    private OrderService orderService;

    @Mock
    private UserService userService;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private MessageController messageController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        SecurityContextHolder.setContext(securityContext);
    }


    @Test
    void sendMessage_UserNotFound_ShouldThrowException() {
        // Arrange
        String senderUsername = "sender";
        MessageDto messageDto = new MessageDto();
        messageDto.setRecipientUsername("recipient");
        messageDto.setOrderId(1L);
        messageDto.setContent("Test message");

        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(senderUsername);
        when(userService.getUserEntity(senderUsername)).thenReturn(null);

        // Act & Assert
        assertThrows(RuntimeException.class, () -> {
            messageController.sendMessage(messageDto);
        });
    }

    @Test
    void sendMessage_OrderNotFound_ShouldThrowException() {
        // Arrange
        String senderUsername = "sender";
        User sender = new User();
        sender.setUsername(senderUsername);

        User recipient = new User();
        recipient.setUsername("recipient");

        MessageDto messageDto = new MessageDto();
        messageDto.setRecipientUsername("recipient");
        messageDto.setOrderId(1L);
        messageDto.setContent("Test message");

        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(senderUsername);
        when(userService.getUserEntity(senderUsername)).thenReturn(sender);
        when(userService.getUserEntity("recipient")).thenReturn(recipient);
        when(orderService.getOrderEntity(1L)).thenReturn(null);

        // Act & Assert
        assertThrows(RuntimeException.class, () -> {
            messageController.sendMessage(messageDto);
        });
    }
}