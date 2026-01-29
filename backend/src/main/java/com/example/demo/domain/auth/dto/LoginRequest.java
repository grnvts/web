package com.example.demo.domain.auth.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String username;
    private String password;
    private String captchaValue;
} 
