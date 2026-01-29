package com.example.demo.service.impl;

import org.slf4j.Logger;
import org.springframework.stereotype.Service;

import com.example.demo.error.ForbiddenException;
import com.example.demo.error.NotFoundException;
import com.example.demo.jwt.config.JwtTokenUtil;
import com.example.demo.model.User;

import com.example.demo.repo.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ControlService {
	public static final String TOKEN_PREFIX = "Bearer ";
	private final Logger logger;
	private final JwtTokenUtil tokenUtil;
	private final UserRepository userRepository;
	
	public void controlUsername(String authHeader,String username) {
		String userNameFromToken = getUsernameFromToken(authHeader);
		if(!userNameFromToken.equals(username)){
			logger.error("User names do not match");
			throw new ForbiddenException("User names do not match");
		}
	}
	public User getUser(String username) {
		User user = userRepository.findUserByUsernameWithStatusOne(username);
		if (user==null) {
			logger.error("There is no user with {}", username);
			throw new NotFoundException();
		}
		return user;
	}
	public String getUsernameFromToken(String authHeader) {
		String username= null;
		if(authHeader != null && authHeader.startsWith(TOKEN_PREFIX)) {
			String token = authHeader.replace(TOKEN_PREFIX, "");
			username = tokenUtil.getUsernameFromToken(token);
		}
		return username;
	}
}
