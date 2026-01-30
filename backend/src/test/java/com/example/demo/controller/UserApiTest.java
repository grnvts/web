package com.example.demo.controller;

import com.example.demo.domain.users.controller.UserApi;
import com.example.demo.domain.users.dto.UserDto;
import com.example.demo.domain.users.service.UserService;
import com.example.demo.domain.common.config.jwt.JwtUserDetails;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class UserApiTest {

    @Mock
    private UserService userService;

    @InjectMocks
    private UserApi userApi;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testGetAllUsers() {
        @SuppressWarnings("unchecked")
        Page<UserDto> mockPage = mock(Page.class);
        JwtUserDetails principal = mock(JwtUserDetails.class);
        when(principal.getUsername()).thenReturn("user1");
        Pageable pageable = mock(Pageable.class);
        when(userService.getAll(pageable, "user1")).thenReturn(mockPage);

        ResponseEntity<Page<UserDto>> response = userApi.getAll(principal, pageable);

        assertEquals(mockPage, response.getBody());
        verify(userService, times(1)).getAll(pageable, "user1");
    }

    @Test
    void testRestoreUser() {
        Long userId = 1L;
        ResponseEntity<Boolean> response = userApi.restoreUser(userId);

        assertEquals(true, response.getBody());
        verify(userService, times(1)).restoreUser(userId);
    }

    @Test
    void testGetAllMasters() {
        List<UserDto> masters = Arrays.asList(new UserDto(), new UserDto());
        when(userService.findAllMasters()).thenReturn(masters);

        List<UserDto> response = userApi.getAllMasters();

        assertEquals(2, response.size());
        verify(userService, times(1)).findAllMasters();
    }
}
