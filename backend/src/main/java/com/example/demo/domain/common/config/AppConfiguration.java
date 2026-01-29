package com.example.demo.domain.common.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import lombok.Data;

@Data
@Configuration
@ConfigurationProperties(prefix = "app")
public class AppConfiguration {
	private String uploadPath;
	private String jwtSecret;
	private String recaptchaSecretKey;
}
