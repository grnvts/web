package com.example.demo.controller;

import com.example.demo.domain.common.config.jwt.JwtUserDetails;
import com.example.demo.domain.notifications.controller.MessageController;
import com.example.demo.domain.notifications.dto.MessageDto;
import com.example.demo.domain.notifications.model.Message;
import com.example.demo.domain.notifications.service.MessageService;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.orders.service.OrderService;
import com.example.demo.domain.users.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.ResponseEntity;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class MessageControllerTest {

    @Mock
    private MessageService messageService;

    @Mock
    private OrderService orderService;

    @Mock
    private UserService userService;

    @InjectMocks
    private MessageController messageController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }


    @Test
    void sendMessage_ShouldDelegateToServiceAndReturnDto() {
        JwtUserDetails principal = mock(JwtUserDetails.class);
        User sender = new User();
        sender.setId(1L);
        sender.setUsername("sender");

        User recipient = new User();
        recipient.setId(2L);
        recipient.setUsername("recipient");

        Order order = new Order();
        order.setId(10L);

        MessageDto messageDto = new MessageDto();
        messageDto.setRecipientUsername("recipient");
        messageDto.setOrderId(10L);
        messageDto.setContent("Test message");

        Message savedMessage = new Message();
        savedMessage.setId(100L);
        savedMessage.setSender(sender);
        savedMessage.setRecipient(recipient);
        savedMessage.setOrder(order);
        savedMessage.setContent("Test message");

        when(principal.getUsername()).thenReturn("sender");
        when(userService.getUserEntity("sender")).thenReturn(sender);
        when(userService.getUserEntity("recipient")).thenReturn(recipient);
        when(orderService.getOrderEntity(10L)).thenReturn(order);
        when(messageService.sendMessage(sender, recipient, order, "Test message"))
                .thenReturn(savedMessage);

        ResponseEntity<?> response = messageController.sendMessage(principal, messageDto);

        assertEquals(200, response.getStatusCode().value());
        MessageDto body = (MessageDto) response.getBody();
        assertEquals(100L, body.getId());
        assertEquals("sender", body.getSenderUsername());
        assertEquals("recipient", body.getRecipientUsername());
        assertEquals(10L, body.getOrderId());
        assertEquals("Test message", body.getContent());
        verify(messageService).sendMessage(sender, recipient, order, "Test message");
        verifyNoMoreInteractions(messageService);
    }
}
