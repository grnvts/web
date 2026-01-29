package com.example.demo.domain.auth.service;

import com.example.demo.domain.common.config.AppConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Service
public class RecaptchaService {
    private static final Logger logger = LoggerFactory.getLogger(RecaptchaService.class);

    private final AppConfiguration appConfiguration;
    private final RestTemplate restTemplate;

    @Autowired
    public RecaptchaService(AppConfiguration appConfiguration) {
        this.appConfiguration = appConfiguration;
        this.restTemplate = new RestTemplate();
    }

    public boolean verifyRecaptcha(String recaptchaResponse) {
        logger.info("Verifying reCAPTCHA response: {}", recaptchaResponse);
        
        if (recaptchaResponse == null || recaptchaResponse.isEmpty()) {
            logger.error("reCAPTCHA response is null or empty");
            return false;
        }

        String url = "https://www.google.com/recaptcha/api/siteverify";
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
        map.add("secret", appConfiguration.getRecaptchaSecretKey());
        map.add("response", recaptchaResponse);

        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(map, headers);

        try {
            logger.info("Sending verification request to Google reCAPTCHA API");
            ResponseEntity<Map> response = restTemplate.postForEntity(url, request, Map.class);
            Map<String, Object> responseBody = response.getBody();
            logger.info("reCAPTCHA verification response: {}", responseBody);
            
            boolean success = responseBody != null && (Boolean) responseBody.get("success");
            if (!success && responseBody != null) {
                logger.error("reCAPTCHA verification failed: {}", responseBody.get("error-codes"));
            }
            return success;
        } catch (Exception e) {
            logger.error("Error verifying reCAPTCHA", e);
            return false;
        }
    }
} 
