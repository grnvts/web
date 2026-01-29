package com.example.demo.model.annotation;

import com.example.demo.domain.common.validation.UniqueUsernameValidator;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.repo.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import jakarta.validation.ConstraintValidatorContext;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UniqueUsernameValidatorTest {

    @InjectMocks
    private UniqueUsernameValidator validator;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ConstraintValidatorContext context;

    @Test
    public void testIsValid_WhenUsernameIsUnique_ShouldReturnTrue() {
        // Arrange
        String uniqueUsername = "uniqueUser";
        when(userRepository.findByUsername(uniqueUsername)).thenReturn(null);

        // Act
        boolean result = validator.isValid(uniqueUsername, context);

        // Assert
        assertTrue(result);
        verify(userRepository, times(1)).findByUsername(uniqueUsername);
    }

    @Test
    public void testIsValid_WhenUsernameIsNotUnique_ShouldReturnFalse() {
        // Arrange
        String existingUsername = "existingUser";
        User existingUser = new User();
        existingUser.setUsername(existingUsername);
        when(userRepository.findByUsername(existingUsername)).thenReturn(existingUser);

        // Act
        boolean result = validator.isValid(existingUsername, context);

        // Assert
        assertFalse(result);
        verify(userRepository, times(1)).findByUsername(existingUsername);
    }
}
