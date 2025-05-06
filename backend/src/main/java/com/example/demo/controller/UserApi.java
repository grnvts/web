package com.example.demo.controller;

import javax.validation.Valid;

import com.example.demo.dto.*;
import com.example.demo.model.Qualification;
import com.example.demo.repo.QualificationRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import com.example.demo.model.User;
import com.example.demo.service.UserService;
import com.example.demo.util.ApiPaths;

import lombok.RequiredArgsConstructor;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
@RequestMapping(ApiPaths.UserCtrl.CTRL)
@CrossOrigin
public class UserApi {
	private final UserService service;
	private final QualificationRepository qualificationRepository;

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
	@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
	@DeleteMapping("/{id}")
	public ResponseEntity<Boolean> deleteUser(@PathVariable Long id) {
    	return ResponseEntity.ok(service.deleteUser(id));
	}

	@GetMapping("/masters")
	@PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_BRIGADIER')")
	public List<UserDto> getAllMasters() {
		return service.findAllMasters();
	}

	@GetMapping("/qualifications")
	@PreAuthorize("hasRole('ROLE_ADMIN')")
	public ResponseEntity<List<QualificationDto>> getAllQualifications() {
		List<Qualification> qualifications = qualificationRepository.findAll();
		System.out.println("Найдено квалификаций: " + qualifications.size());
		
		List<QualificationDto> qualificationDtos = qualifications.stream()
			.map(q -> new QualificationDto(q.getId(), q.getName()))
			.collect(Collectors.toList());
			
		return ResponseEntity.ok(qualificationDtos);
	}


	@PostMapping("/masters")
	@PreAuthorize("hasRole('ROLE_ADMIN')")
	public ResponseEntity<?> createMaster(@RequestBody CreateMasterDto dto) {
		return service.createMaster(dto);
	}
}
