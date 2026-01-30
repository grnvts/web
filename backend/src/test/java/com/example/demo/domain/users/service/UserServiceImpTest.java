package com.example.demo.domain.users.service;

import com.example.demo.domain.common.error.BadRequestException;
import com.example.demo.domain.users.dto.UserDto;
import com.example.demo.domain.users.model.Role;
import com.example.demo.domain.users.model.RoleName;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.repo.RoleRepository;
import com.example.demo.domain.users.repo.UserRepository;
import com.example.demo.domain.users.service.impl.UserServiceImp;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.modelmapper.ModelMapper;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.slf4j.Logger;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserServiceImpTest {

    @Mock
    UserRepository userRepository;
    @Mock
    RoleRepository roleRepository;
    @Mock
    PasswordEncoder passwordEncoder;
    @Mock
    Logger logger;

    private UserServiceImp service;

    @BeforeEach
    void setUp() {
        service = new UserServiceImp(
                userRepository,
                new ModelMapper(),
                logger,
                passwordEncoder,
                null,
                roleRepository,
                null,
                null
        );
    }

    @Test
    void createUserWithRoles_shouldThrow_ifUsernameExists() {
        UserDto dto = new UserDto();
        dto.setUsername("john");
        dto.setEmail("john@example.com");
        dto.setPassword("Password1");
        dto.setRoles(Set.of("ROLE_USER"));
        when(userRepository.findByUsername("john")).thenReturn(new User());

        assertThrows(BadRequestException.class, () -> service.createUserWithRoles(dto));
    }

    @Test
    void createUserWithRoles_shouldThrow_ifEmailExists() {
        UserDto dto = new UserDto();
        dto.setUsername("john2");
        dto.setEmail("john@example.com");
        dto.setPassword("Password1");
        dto.setRoles(Set.of("ROLE_USER"));
        when(userRepository.findByEmail("john@example.com")).thenReturn(new User());

        assertThrows(BadRequestException.class, () -> service.createUserWithRoles(dto));
    }

    @Test
    void save_shouldThrow_ifPasswordsMismatch() {
        User user = new User();
        user.setUsername("u");
        user.setEmail("e@e.com");
        user.setPassword("a");
        user.setRepeatPassword("b");
        assertThrows(BadRequestException.class, () -> service.save(user));
    }

    @Test
    void createUserWithRoles_shouldThrow_ifRoleMissing() {
        UserDto dto = new UserDto();
        dto.setUsername("john3");
        dto.setEmail("john3@example.com");
        dto.setPassword("Password1");
        dto.setRoles(Set.of("ROLE_ADMIN"));
        when(roleRepository.findByName(RoleName.ROLE_ADMIN)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () -> service.createUserWithRoles(dto));
    }
}
