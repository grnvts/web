package com.example.demo.service;

import com.example.demo.dto.UserDto;
import com.example.demo.error.BadRequestException;
import com.example.demo.model.User;
import com.example.demo.repo.BrigadeRepository;
import com.example.demo.repo.QualificationRepository;
import com.example.demo.repo.RoleRepository;
import com.example.demo.repo.UserRepository;
import com.example.demo.service.impl.UserServiceImp;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.modelmapper.ModelMapper;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.slf4j.Logger;
import org.springframework.security.crypto.password.PasswordEncoder;

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
    QualificationRepository qualificationRepository;
    @Mock
    BrigadeRepository brigadeRepository;
    @Mock
    PasswordEncoder passwordEncoder;
    @Mock
    Logger logger;

    private ModelMapper mapper;
    private UserServiceImp service;

    @BeforeEach
    void setUp() {
        mapper = new ModelMapper();
        service = new UserServiceImp(
                userRepository,
                mapper,
                logger,
                passwordEncoder,
                null, // FileService not needed in these tests
                roleRepository,
                qualificationRepository,
                brigadeRepository
        );
    }

    @Test
    void createUserWithRoles_shouldThrow_whenUsernameExists() {
        UserDto dto = new UserDto();
        dto.setUsername("john");
        dto.setEmail("john@example.com");
        dto.setPassword("Password1");
        dto.setRoles(Set.of("ROLE_USER"));

        when(userRepository.findByUsername("john")).thenReturn(new User());

        assertThrows(BadRequestException.class, () -> service.createUserWithRoles(dto));
    }

    @Test
    void save_shouldThrow_whenPasswordsDoNotMatch() {
        User user = new User();
        user.setUsername("alice");
        user.setEmail("alice@example.com");
        user.setPassword("Password1");
        user.setRepeatPassword("Password2");

        assertThrows(BadRequestException.class, () -> service.save(user));
    }
}
