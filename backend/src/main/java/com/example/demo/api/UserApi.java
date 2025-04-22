package com.example.demo.api;

import javax.validation.Valid;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import com.example.demo.dto.UploadImageDto;
import com.example.demo.dto.UserDto;
import com.example.demo.dto.UserUpdateDto;
import com.example.demo.model.User;
import com.example.demo.service.UserService;
import com.example.demo.util.ApiPaths;

import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping(ApiPaths.UserCtrl.CTRL)
@CrossOrigin
public class UserApi {
	private final UserService service;

	// localhost:8501/api/user/users?page=1&size=4
	@PreAuthorize("hasRole('ADMIN')")
	@GetMapping("/users")
	public ResponseEntity<Page<UserDto>> getAll(@RequestHeader("Authorization") String authHeader, Pageable page) {

		return ResponseEntity.ok(service.getAll(page, authHeader));
	}
	@PreAuthorize("hasRole('ROLE_ADMIN')")
	@PutMapping("/{id}/restore")
	public ResponseEntity<Boolean> restoreUser(@PathVariable Long id) {
		return ResponseEntity.ok(service.restoreUser(id));
	}






	@PreAuthorize("hasRole('ADMIN')")
	@PostMapping("/create")
	public ResponseEntity<?> createUserWithRoles(@Valid @RequestBody UserDto dto) {
		return service.createUserWithRoles(dto);
	}

	@GetMapping("/{username}")
	public ResponseEntity<UserDto> getUser(@PathVariable String username) {
		return ResponseEntity.ok(service.getUser(username));
	}

	@PostMapping
	public ResponseEntity<?> postUser(@Valid @RequestBody User dto) {
		return ResponseEntity.ok(service.save(dto));
	}

	@PutMapping("/{username}")
	public ResponseEntity<?> updateUser(@RequestHeader("Authorization") String authHeader,
			@PathVariable String username,@Valid @RequestBody UserUpdateDto dto) {

		return ResponseEntity.ok(service.updateUser(authHeader, username, dto));
	}
	@PutMapping("/upload-image/{username}")
	public ResponseEntity<?> uploadImage(@RequestHeader("Authorization") String authHeader,
			@PathVariable String username,@RequestBody UploadImageDto dto) { 
		return ResponseEntity.ok(service.uploadImage(authHeader, username, dto));
	}
	@PreAuthorize("hasRole('ROLE_ADMIN')")
	@DeleteMapping("/{id}")
	public ResponseEntity<Boolean> deleteUser(@PathVariable Long id) {
    	return ResponseEntity.ok(service.deleteUser(id));
	}

}
