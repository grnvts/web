package com.example.demo.domain.users.port;

import com.example.demo.domain.users.model.RoleName;
import com.example.demo.domain.users.model.User;

import java.util.List;

public interface UserAccessPort {
    User findActiveByUsername(String username);
    User findByUsername(String username);
    User findById(Long id);
    List<User> findAll();
    List<User> findAllByIds(List<Long> ids);
    List<User> findAllByRole(RoleName roleName);
}
