package com.example.demo.domain.orders.controller;

import com.example.demo.domain.orders.dto.BrigadeDto;
import com.example.demo.domain.orders.model.Brigade;
import com.example.demo.domain.orders.repo.BrigadeRepository;
import com.example.demo.domain.users.dto.UserDto;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;
import com.example.demo.domain.users.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/brigade")
@RequiredArgsConstructor
public class BrigadeController {

    private final BrigadeRepository brigadeRepository;
    private final UserAccessPort userAccessPort;
    private final UserService userService;

    @Operation(summary = "Get brigade masters", description = "Retrieve all masters in a specific brigade")
    @GetMapping("/{brigadeId}/masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public List<UserDto> getBrigadeMasters(@PathVariable Long brigadeId) {
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        return brigade.getMasters().stream().map(UserDto::new).collect(Collectors.toList());
    }

    @Operation(summary = "Add master to brigade", description = "Add a master to a specific brigade")
    @PostMapping("/{brigadeId}/add-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> addMasterToBrigade(@PathVariable Long brigadeId, @RequestBody Map<String, Long> body) {
        Long userId = body.get("userId");
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        User master = userAccessPort.findById(userId);
        if (master == null) throw new RuntimeException("User not found");
        if (!brigade.getMasters().contains(master)) {
            brigade.getMasters().add(master);
            brigadeRepository.save(brigade);
        }
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Remove master from brigade", description = "Remove a master from a specific brigade")
    @PostMapping("/{brigadeId}/remove-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> removeMasterFromBrigade(@PathVariable Long brigadeId, @RequestBody Map<String, Long> body) {
        Long userId = body.get("userId");
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        User master = userAccessPort.findById(userId);
        if (master == null) throw new RuntimeException("User not found");
        brigade.getMasters().remove(master);
        brigadeRepository.save(brigade);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Get all brigades", description = "Retrieve a list of all brigades (admin only)")
    @GetMapping("/all")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public List<BrigadeDto> getAllBrigades() {
        return brigadeRepository.findAll().stream()
                .map(BrigadeDto::new)
                .collect(Collectors.toList());
    }

    @Operation(summary = "Get my brigade masters", description = "Retrieve all masters in the authenticated brigadier's brigade")
    @GetMapping("/my/masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public List<UserDto> getMyBrigadeMasters(Authentication authentication) {
        User brigadier = userAccessPort.findByUsername(authentication.getName());
        if (brigadier == null) throw new RuntimeException("User not found");
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));
        return brigade.getMasters().stream().map(UserDto::new).collect(Collectors.toList());
    }

    @Operation(summary = "Remove master from my brigade", description = "Remove a master from the authenticated brigadier's brigade")
    @PostMapping("/my/remove-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public ResponseEntity<?> removeMasterFromMyBrigade(@RequestBody Map<String, Long> body, Authentication authentication) {
        String username = authentication.getName();
        User brigadier = userAccessPort.findByUsername(username);
        if (brigadier == null) throw new RuntimeException("User not found");
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));
        Long userId = body.get("userId");
        User master = userAccessPort.findById(userId);
        if (master == null) throw new RuntimeException("User not found");
        brigade.getMasters().remove(master);
        brigadeRepository.save(brigade);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Add master to my brigade", description = "Add a master to the authenticated brigadier's brigade")
    @PostMapping("/my/add-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public ResponseEntity<?> addMasterToMyBrigade(@RequestBody Map<String, Long> body, Authentication authentication) {
        String username = authentication.getName();
        User brigadier = userAccessPort.findByUsername(username);
        if (brigadier == null) throw new RuntimeException("User not found");
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));
        Long userId = body.get("userId");
        User master = userAccessPort.findById(userId);
        if (master == null) throw new RuntimeException("User not found");
        if (!brigade.getMasters().contains(master)) {
            brigade.getMasters().add(master);
            brigadeRepository.save(brigade);
        }
        return ResponseEntity.ok().build();
    }
}
