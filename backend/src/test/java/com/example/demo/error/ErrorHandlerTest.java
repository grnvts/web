package com.example.demo.error;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.boot.web.servlet.error.ErrorAttributes;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.web.context.request.ServletWebRequest;

import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class ErrorHandlerTest {

    @Mock
    private ErrorAttributes errorAttributes;

    private ErrorHandler errorHandler;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        errorHandler = new ErrorHandler();
        errorHandler.errorAttributes = errorAttributes;
    }


    @Test
    void testHandleError_WithoutValidationErrors() {
        // Arrange
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();
        ServletWebRequest webRequest = new ServletWebRequest(request, response);

        Map<String, Object> attributes = new HashMap<>();
        attributes.put("message", "Internal Server Error");
        attributes.put("path", "/api/test");
        attributes.put("status", 500);

        when(errorAttributes.getErrorAttributes(webRequest, true)).thenReturn(attributes);

        // Act
        ApiError apiError = errorHandler.handleError(webRequest);

        // Assert
        assertThat(apiError.getStatus()).isEqualTo(500);
        assertThat(apiError.getMessage()).isEqualTo("Internal Server Error");
        assertThat(apiError.getPath()).isEqualTo("/api/test");
        assertThat(apiError.getValidationErrors()).isNull();
    }

    @Test
    void testGetErrorPath() {
        // Act
        String errorPath = errorHandler.getErrorPath();

        // Assert
        assertThat(errorPath).isNull();
    }
}