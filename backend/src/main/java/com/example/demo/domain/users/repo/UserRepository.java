package com.example.demo.domain.users.repo;

import java.util.List;
import java.util.Optional;

import com.example.demo.domain.users.model.RoleName;
import com.example.demo.domain.users.port.UserRepositoryPort;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.model.Role;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
@Repository
public interface UserRepository extends JpaRepository<User, Long>, UserRepositoryPort {

	User findByUsername(String username);
	Optional<User> findUserByUsername(String username);

	@Query("SELECT u FROM User u WHERE u.username <> :username")
	Page<User> findByUsernameNot(String username, Pageable page);
	
	@Query("select u from User u where u.id = :id and u.status = 1")
	Optional<User> findUserById(Long id);

	@Query("SELECT u FROM User u JOIN FETCH u.roles WHERE u.username = :username and u.status = 1")
	Optional<User> findByUsernameWithRoles(@Param("username") String username);

	@Query("SELECT u FROM User u JOIN FETCH u.roles  WHERE u.username = :username and u.status = 1")
	List<User> findAllWithRoles();

	@Query("SELECT u FROM User u JOIN FETCH u.roles WHERE u.username = :username and u.status = 1")
	User findUserByUsernameWithStatusOne(String username);

	List<User> findByRoles_Name(RoleName roles_name);

	List<User> findByRolesContainsOrderByUsernameAsc(Role role);


	@Query("select u from User u where u.email = :email and u.status = 1")
	User findByEmail(@NotEmpty @Size(min = 5, max = 200) String email);
}
