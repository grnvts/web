package com.example.demo.domain.users.service;

import com.example.demo.domain.users.model.RoleName;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;
import com.example.demo.domain.users.port.UserRepositoryPort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserAccessAdapter implements UserAccessPort {
    private final UserRepositoryPort userRepository;

    @Override
    public User findActiveByUsername(String username) {
        return userRepository.findUserByUsernameWithStatusOne(username);
    }

    @Override
    public User findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    @Override
    public List<User> findAll() {
        return userRepository.findAll();
    }

    @Override
    public User findById(Long id) {
        return userRepository.findById(id).orElse(null);
    }

    @Override
    public List<User> findAllByIds(List<Long> ids) {
        return userRepository.findAllById(ids);
    }

    @Override
    public List<User> findAllByRole(RoleName roleName) {
        return userRepository.findAll().stream()
                .filter(user -> user.getRoles().stream().anyMatch(r -> r.getName().equals(roleName)))
                .collect(Collectors.toList());
    }
}
