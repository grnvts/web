package com.example.demo.domain.common.config.websocket;

import com.example.demo.domain.common.config.jwt.JwtTokenUtil;
import com.example.demo.domain.common.config.jwt.JwtUserDetailsService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class WebSocketAuthChannelInterceptor implements ChannelInterceptor {

    private final JwtTokenUtil jwtTokenUtil;
    private final JwtUserDetailsService jwtUserDetailsService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);
        if (!StompCommand.CONNECT.equals(accessor.getCommand())) {
            return message;
        }

        String rawHeader = extractAuthorizationHeader(accessor);
        if (rawHeader == null || !rawHeader.startsWith("Bearer ")) {
            return message;
        }

        String token = rawHeader.substring(7);
        String username = jwtTokenUtil.getUsernameFromToken(token);
        UserDetails userDetails = jwtUserDetailsService.loadUserByUsername(username);
        if (!jwtTokenUtil.validateToken(token, userDetails)) {
            return message;
        }

        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );

        accessor.setUser(authentication);
        SecurityContextHolder.getContext().setAuthentication(authentication);
        return message;
    }

    private String extractAuthorizationHeader(StompHeaderAccessor accessor) {
        List<String> authorization = accessor.getNativeHeader("Authorization");
        if (authorization != null && !authorization.isEmpty()) {
            return authorization.get(0);
        }
        List<String> authLower = accessor.getNativeHeader("authorization");
        if (authLower != null && !authLower.isEmpty()) {
            return authLower.get(0);
        }
        return null;
    }
}
