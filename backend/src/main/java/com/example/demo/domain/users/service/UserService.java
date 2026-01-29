package com.example.demo.domain.users.service;

import java.util.List;

import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.example.demo.domain.orders.dto.CreateMasterDto;
import com.example.demo.domain.users.dto.UploadImageDto;
import com.example.demo.domain.users.dto.UserDto;
import com.example.demo.domain.users.dto.UserUpdateDto;
import com.example.demo.domain.users.model.User;

public interface UserService {
	UserDto save(@Valid User user);

	void deleteUser(Long id);

	UserDto getUser(String username);

	Page<UserDto> getAll(Pageable page, String currentUsername);

	void restoreUser(Long id);

	UserDto updateUser(String requester, String username, UserUpdateDto dto);

	UserDto createUserWithRoles(UserDto dto);

	UserDto uploadImage(String requester, String username, UploadImageDto dto);

	UserDto createMaster(CreateMasterDto dto);

	User getUserEntity(String username);

	List<UserDto> findAllMasters();
}
