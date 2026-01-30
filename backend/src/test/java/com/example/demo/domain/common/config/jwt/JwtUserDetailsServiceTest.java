package com.example.demo.domain.common.config.jwt;

import com.example.demo.domain.users.model.Role;
import com.example.demo.domain.users.model.RoleName;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class JwtUserDetailsServiceTest {

    @Mock
    UserAccessPort userAccessPort;

    @InjectMocks
    JwtUserDetailsService service;

    @Test
    void loadUserByUsername_whenUserMissing_shouldThrow() {
        when(userAccessPort.findActiveByUsername("missing")).thenReturn(null);
        assertThrows(UsernameNotFoundException.class, () -> service.loadUserByUsername("missing"));
    }

    @Test
    void loadUserByUsername_shouldReturnJwtUserDetails() {
        User user = new User();
        user.setId(1L);
        user.setUsername("john");
        user.setPassword("pwd");
        Role role = new Role();
        role.setName(RoleName.ROLE_USER);
        user.setRoles(Set.of(role));

        when(userAccessPort.findActiveByUsername("john")).thenReturn(user);

        var details = service.loadUserByUsername("john");
        assertEquals("john", details.getUsername());
        assertEquals("pwd", details.getPassword());
    }
}
