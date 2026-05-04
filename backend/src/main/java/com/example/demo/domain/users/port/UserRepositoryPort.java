package com.example.demo.domain.users.port;

import com.example.demo.domain.users.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface UserRepositoryPort {
    User save(User user);

    Page<User> findByUsernameNot(String username, Pageable page);

    Page<User> findAll(Pageable page);

    List<User> findAll();

    Optional<User> findById(Long id);

    List<User> findAllById(Iterable<Long> ids);

    User findUserByUsernameWithStatusOne(String username);

    User findByUsername(String username);

    Optional<User> findUserByUsername(String username);

    User findByEmail(String email);
}
