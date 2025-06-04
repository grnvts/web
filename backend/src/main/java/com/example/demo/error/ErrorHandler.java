package com.example.demo.error;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.servlet.error.ErrorAttributes;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.WebRequest;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
public class ErrorHandler implements ErrorController {

    @Autowired
    ErrorAttributes errorAttributes;

    @Operation(summary = "Handle application errors", description = "Handle and return detailed error information for the application")
    @RequestMapping("/error")
    public ApiError handleError(WebRequest webRequest) {
        Map<String, Object> attributes = this.errorAttributes.getErrorAttributes(webRequest, true);
        String message = (String) attributes.get("message");
        String path = (String) attributes.get("path");
        int status = (Integer) attributes.get("status");
        ApiError error = new ApiError(status, message, path);
        if (attributes.containsKey("errors")) {
            @SuppressWarnings("unchecked")
            List<FieldError> fieldErrors = (List<FieldError>) attributes.get("errors");
            Map<String, String> validationErrors = new HashMap<>();
            for (FieldError fieldError : fieldErrors) {
                validationErrors.put(fieldError.getField(), fieldError.getDefaultMessage());
            }
            error.setValidationErrors(validationErrors);
        }
        return error;
    }

    @Override
    public String getErrorPath() {
        return null;
    }
}