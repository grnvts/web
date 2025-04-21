package com.example.demo.repo;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.example.demo.dto.UserDto;
import com.example.demo.model.User;
import org.springframework.data.repository.query.Param;

import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.Size;

public interface UserRepository extends JpaRepository<User, Long> {

	User findByUsername(String username);
	
	Page<User> findByUsernameNot(String username, Pageable page);
	
	@Query("select u from User u where u.id = :id and u.status = 1")
	Optional<User> findUserById(Long id);

	@Query("SELECT u FROM User u JOIN FETCH u.roles WHERE u.username = :username")
	Optional<User> findByUsernameWithRoles(@Param("username") String username);

	@Query("SELECT u FROM User u JOIN FETCH u.roles")
	List<User> findAllWithRoles();

	@Query("SELECT u FROM User u JOIN FETCH u.roles WHERE u.username = :username and u.status = 1")
	User findUserByUsernameWithStatusOne(String username);


	@Query("select u from User u where u.email = :email and u.status = 1")
	User findByEmail(@NotEmpty @Size(min = 5, max = 200) String email);
}
