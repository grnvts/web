package com.example.demo.api;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import com.example.demo.error.ApiError;
import com.example.demo.jwt.config.JwtRequest;
import com.example.demo.jwt.config.JwtResponse;
import com.example.demo.jwt.config.JwtTokenUtil;
import com.example.demo.jwt.config.JwtUserDetailsService;
import com.example.demo.model.User;
import com.example.demo.repo.UserRepository;
import com.example.demo.service.RecaptchaService;
import com.example.demo.util.ApiPaths;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@CrossOrigin
@RequestMapping(ApiPaths.LoginCtrl.CTRL)
@RequiredArgsConstructor
public class JwtAuthenticationController {
    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationController.class);

    @Autowired
    private final AuthenticationManager authenticationManager;

    @Autowired
    private final JwtTokenUtil jwtTokenUtil;

    @Autowired
    private final UserRepository userRepository;

    @Autowired
    private final JwtUserDetailsService userDetailsService;

    @Autowired
    private final RecaptchaService recaptchaService;

    @Operation(summary = "Authenticate user", description = "Authenticate a user and return a JWT token along with user details")
    @PostMapping
    public ResponseEntity<?> createAuthenticationToken(@RequestBody JwtRequest authenticationRequest) throws Exception {
        try {
            logger.info("Received login request for user: {}", authenticationRequest.getUsername());
            
            // Проверяем капчу
            if (!recaptchaService.verifyRecaptcha(authenticationRequest.getCaptchaValue())) {
                logger.error("reCAPTCHA verification failed for user: {}", authenticationRequest.getUsername());
                ApiError error = new ApiError(400, "Неверная капча", "/api/login");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
            }

            logger.info("reCAPTCHA verification successful, proceeding with authentication");
            
            Authentication authentication = authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(
                    authenticationRequest.getUsername(), authenticationRequest.getPassword()));

            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = jwtTokenUtil.generateToken(authentication);
            String username = authenticationRequest.getUsername();
            User user = userRepository.findByUsername(username);
            Set<String> roleNames = user.getRoles().stream()
                    .map(role -> role.getName().name())
                    .collect(Collectors.toSet());
            
            logger.info("User {} successfully authenticated", username);
            return ResponseEntity.ok(new JwtResponse(username, jwt, user.getEmail(), user.getImage(), roleNames));
        } catch (BadCredentialsException e) {
            logger.error("Authentication failed for user: {}", authenticationRequest.getUsername(), e);
            ApiError error = new ApiError(401, "Unauthorized request: " + e.getMessage(), "/api/login");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        } catch (Exception e) {
            logger.error("Unexpected error during authentication", e);
            throw e;
        }
    }
}