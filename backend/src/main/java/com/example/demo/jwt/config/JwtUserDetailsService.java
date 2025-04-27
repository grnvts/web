package com.example.demo.jwt.config;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.repo.UserRepository;

@Service
public class JwtUserDetailsService implements UserDetailsService {
	
	@Autowired
    UserRepository userRepository;

	@Override
	@Transactional
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		com.example.demo.model.User user = userRepository.findUserByUsernameWithStatusOne(username);

		if (user == null) {
			throw new UsernameNotFoundException("Invalid username or password.");
		}

		// Извлекаем роли пользователя
		List<SimpleGrantedAuthority> authorities = user.getRoles().stream()
				.map(role -> new SimpleGrantedAuthority(role.getName().name()))
				.collect(Collectors.toList());
		return new org.springframework.security.core.userdetails.User(
				user.getUsername(),
				user.getPassword(),
				authorities
		);
	}
}
