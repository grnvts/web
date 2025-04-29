package com.example.demo.service;

import java.util.List;

import javax.validation.Valid;

import com.example.demo.dto.CreateMasterDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;

import com.example.demo.dto.UploadImageDto;
import com.example.demo.dto.UserDto;
import com.example.demo.dto.UserUpdateDto;
import com.example.demo.model.User;

public interface UserService {
	ResponseEntity<?> save(@Valid User user);

	Boolean deleteUser(Long id);

	UserDto getUser(String username);

	Page<UserDto> getAll(Pageable page,String authHeader ) ;

	Boolean restoreUser(Long id);

	ResponseEntity<?> updateUser(String authHeader,String username,UserUpdateDto dto);

	ResponseEntity<?> createUserWithRoles(UserDto dto);

	ResponseEntity<?> uploadImage(String authHeader, String username, UploadImageDto dto);


	ResponseEntity<?> createMaster(CreateMasterDto dto);
	User getUserEntity(String username);

	List<UserDto> findAllMasters();
}
