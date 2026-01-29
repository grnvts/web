package com.example.demo.domain.users.controller;

import com.example.demo.domain.orders.dto.CreateMasterDto;
import com.example.demo.domain.users.dto.QualificationDto;
import com.example.demo.domain.users.dto.UploadImageDto;
import com.example.demo.domain.users.dto.UserDto;
import com.example.demo.domain.users.dto.UserUpdateDto;
import jakarta.validation.Valid;

import com.example.demo.domain.users.model.Qualification;
import com.example.demo.domain.users.repo.QualificationRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.service.UserService;
import com.example.demo.domain.common.util.ApiPaths;

import lombok.RequiredArgsConstructor;

import java.util.List;
import java.util.stream.Collectors;

import io.swagger.v3.oas.annotations.Operation;
import com.example.demo.domain.common.config.jwt.JwtUserDetails;

@RestController
@RequiredArgsConstructor
@RequestMapping(ApiPaths.UserCtrl.CTRL)
@CrossOrigin
public class UserApi {
    private final UserService service;
    private final QualificationRepository qualificationRepository;

    @Operation(summary = "Get all users", description = "Retrieve a paginated list of all users")
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/users")
    public ResponseEntity<Page<UserDto>> getAll(@AuthenticationPrincipal JwtUserDetails user, Pageable page) {
        return ResponseEntity.ok(service.getAll(page, user != null ? user.getUsername() : null));
    }

    @Operation(summary = "Restore a user", description = "Restore a previously deleted user by ID")
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}/restore")
    public ResponseEntity<Boolean> restoreUser(@PathVariable Long id) {
        service.restoreUser(id);
        return ResponseEntity.ok(true);
    }

    @Operation(summary = "Create a new user with roles", description = "Create a new user and assign roles")
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/create")
    public ResponseEntity<?> createUserWithRoles(@Valid @RequestBody UserDto dto) {
        return ResponseEntity.ok(service.createUserWithRoles(dto));
    }

    @Operation(summary = "Get user by username", description = "Retrieve user details by username")
    @GetMapping("/{username}")
    public ResponseEntity<UserDto> getUser(@PathVariable String username) {
        return ResponseEntity.ok(service.getUser(username));
    }

    @Operation(summary = "Save a new user", description = "Save a new user to the database")
    @PostMapping
    public ResponseEntity<?> postUser(@Valid @RequestBody User dto) {
        return ResponseEntity.ok(service.save(dto));
    }

    @Operation(summary = "Update user details", description = "Update user details by username")
    @PutMapping("/{username}")
    public ResponseEntity<?> updateUser(@AuthenticationPrincipal JwtUserDetails user,
            @PathVariable String username, @Valid @RequestBody UserUpdateDto dto) {
        return ResponseEntity.ok(service.updateUser(user.getUsername(), username, dto));
    }

    @Operation(summary = "Upload user image", description = "Upload an image for a specific user")
    @PutMapping("/upload-image/{username}")
    public ResponseEntity<?> uploadImage(@AuthenticationPrincipal JwtUserDetails user,
            @PathVariable String username, @RequestBody UploadImageDto dto) {
        return ResponseEntity.ok(service.uploadImage(user.getUsername(), username, dto));
    }

    @Operation(summary = "Delete a user", description = "Delete a user by ID")
    @PreAuthorize("hasAnyRole('ADMIN','USER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteUser(@PathVariable Long id) {
        service.deleteUser(id);
        return ResponseEntity.ok(true);
    }

    @Operation(summary = "Get all masters", description = "Retrieve a list of all masters")
    @GetMapping("/masters")
    @PreAuthorize("hasAnyRole('ADMIN','BRIGADIER')")
    public List<UserDto> getAllMasters() {
        return service.findAllMasters();
    }

    @Operation(summary = "Get all qualifications", description = "Retrieve a list of all qualifications")
    @GetMapping("/qualifications")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<QualificationDto>> getAllQualifications() {
        List<Qualification> qualifications = qualificationRepository.findAll();
        System.out.println("Найдено квалификаций: " + qualifications.size());

        List<QualificationDto> qualificationDtos = qualifications.stream()
                .map(q -> new QualificationDto(q.getId(), q.getName()))
                .collect(Collectors.toList());

        return ResponseEntity.ok(qualificationDtos);
    }

    @Operation(summary = "Create a new master", description = "Create a new master with the provided details")
    @PostMapping("/masters")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createMaster(@RequestBody CreateMasterDto dto) {
        return ResponseEntity.ok(service.createMaster(dto));
    }
}
