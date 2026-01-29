package com.example.demo.domain.users.repo;

import com.example.demo.domain.users.model.Role;
import com.example.demo.domain.users.model.RoleName;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RoleRepository extends JpaRepository<Role, Long> {
    Optional<Role> findByName(RoleName name);
}

