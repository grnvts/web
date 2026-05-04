package com.example.demo.domain.users.port;

import com.example.demo.domain.users.model.Role;
import com.example.demo.domain.users.model.RoleName;

import java.util.Optional;

public interface RoleRepositoryPort {
    Optional<Role> findByName(RoleName name);
}
