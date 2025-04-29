package com.example.demo.controller;

import com.example.demo.dto.UserDto;
import com.example.demo.model.Brigade;
import com.example.demo.model.User;
import com.example.demo.repo.BrigadeRepository;
import com.example.demo.repo.UserRepository;
import com.example.demo.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/brigade")
@RequiredArgsConstructor
public class BrigadeController {

    private final BrigadeRepository brigadeRepository;
    private final UserRepository userRepository;
    private final UserService userService;

    // Получить всех мастеров бригады
    @GetMapping("/{brigadeId}/masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public List<UserDto> getBrigadeMasters(@PathVariable Long brigadeId) {
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        return brigade.getMasters().stream().map(UserDto::new).collect(Collectors.toList());
    }

    // Добавить мастера в бригаду
    @PostMapping("/{brigadeId}/add-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> addMasterToBrigade(@PathVariable Long brigadeId, @RequestBody java.util.Map<String, Long> body) {
        Long userId = body.get("userId");
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        User master = userRepository.findById(userId).orElseThrow();
        if (!brigade.getMasters().contains(master)) {
            brigade.getMasters().add(master);
            brigadeRepository.save(brigade);
        }
        return ResponseEntity.ok().build();
    }

    // Удалить мастера из бригады
    @PostMapping("/{brigadeId}/remove-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> removeMasterFromBrigade(@PathVariable Long brigadeId, @RequestBody java.util.Map<String, Long> body) {
        Long userId = body.get("userId");
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        User master = userRepository.findById(userId).orElseThrow();
        brigade.getMasters().remove(master);
        brigadeRepository.save(brigade);
        return ResponseEntity.ok().build();
    }

    // Получить все бригады (для администратора)
    @GetMapping("/all")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public List<Brigade> getAllBrigades() {
        return brigadeRepository.findAll();
    }

    @GetMapping("/my/masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public List<UserDto> getMyBrigadeMasters(Authentication authentication) {
        User brigadier = userRepository.findUserByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));
        return brigade.getMasters().stream().map(UserDto::new).collect(Collectors.toList());
    }



    // BrigadeController.java

    @PostMapping("/my/remove-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public ResponseEntity<?> removeMasterFromMyBrigade(@RequestBody Map<String, Long> body, Authentication authentication) {
        String username = authentication.getName();
        User brigadier = userRepository.findByUsername(username);
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));
        Long userId = body.get("userId");
        User master = userRepository.findById(userId).orElseThrow();
        brigade.getMasters().remove(master);
        brigadeRepository.save(brigade);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/my/add-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public ResponseEntity<?> addMasterToMyBrigade(@RequestBody Map<String, Long> body, Authentication authentication) {
        String username = authentication.getName();
        User brigadier = userRepository.findByUsername(username);
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));
        Long userId = body.get("userId");
        User master = userRepository.findById(userId).orElseThrow();
        if (!brigade.getMasters().contains(master)) {
            brigade.getMasters().add(master);
            brigadeRepository.save(brigade);
        }
        return ResponseEntity.ok().build();
    }
}