package com.example.demo.domain.auth.controller;

import com.example.demo.domain.common.config.jwt.JwtRequest;
import com.example.demo.domain.common.config.jwt.JwtTokenUtil;
import com.example.demo.domain.common.config.jwt.JwtUserDetailsService;
import com.example.demo.domain.common.error.ApiError;
import com.example.demo.domain.users.model.Role;
import com.example.demo.domain.users.model.RoleName;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;
import com.example.demo.domain.auth.service.RecaptchaService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class JwtAuthenticationControllerTest {

    @Mock AuthenticationManager authenticationManager;
    @Mock JwtTokenUtil jwtTokenUtil;
    @Mock UserAccessPort userAccessPort;
    @Mock JwtUserDetailsService userDetailsService;
    @Mock RecaptchaService recaptchaService;
    @Mock Authentication authentication;

    @InjectMocks JwtAuthenticationController controller;

    @Test
    void createAuthenticationToken_shouldReturnJwt() throws Exception {
        JwtRequest request = new JwtRequest();
        request.setUsername("john");
        request.setPassword("pwd");

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(authentication);
        when(jwtTokenUtil.generateToken(authentication)).thenReturn("jwt");

        User user = new User();
        user.setUsername("john");
        user.setEmail("john@example.com");
        user.setRoles(Set.of(new Role(RoleName.ROLE_USER)));
        when(userAccessPort.findByUsername("john")).thenReturn(user);

        ResponseEntity<?> response = controller.createAuthenticationToken(request);

        assertTrue(response.getStatusCode().is2xxSuccessful());
        var body = (com.example.demo.domain.common.config.jwt.JwtResponse) response.getBody();
        assertEquals("jwt", body.getJwttoken());
    }

    @Test
    void createAuthenticationToken_onBadCredentials_returns401() throws Exception {
        JwtRequest request = new JwtRequest();
        request.setUsername("bad");
        request.setPassword("bad");

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenThrow(new BadCredentialsException("bad"));

        ResponseEntity<?> response = controller.createAuthenticationToken(request);

        assertEquals(401, ((ApiError)response.getBody()).getStatus());
    }
}
