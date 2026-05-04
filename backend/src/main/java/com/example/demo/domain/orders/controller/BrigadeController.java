package com.example.demo.domain.orders.controller;

import com.example.demo.domain.orders.dto.BrigadeDto;
import com.example.demo.domain.orders.service.BrigadeService;
import com.example.demo.domain.users.dto.UserDto;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/brigade")
@RequiredArgsConstructor
public class BrigadeController {

    private final BrigadeService brigadeService;

    @Operation(summary = "Get brigade masters", description = "Retrieve all masters in a specific brigade")
    @GetMapping("/{brigadeId}/masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public List<UserDto> getBrigadeMasters(@PathVariable Long brigadeId) {
        return brigadeService.getBrigadeMasters(brigadeId);
    }

    @Operation(summary = "Add master to brigade", description = "Add a master to a specific brigade")
    @PostMapping("/{brigadeId}/add-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> addMasterToBrigade(@PathVariable Long brigadeId, @RequestBody Map<String, Long> body) {
        Long userId = body.get("userId");
        brigadeService.addMasterToBrigade(brigadeId, userId);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Remove master from brigade", description = "Remove a master from a specific brigade")
    @PostMapping("/{brigadeId}/remove-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<?> removeMasterFromBrigade(@PathVariable Long brigadeId, @RequestBody Map<String, Long> body) {
        Long userId = body.get("userId");
        brigadeService.removeMasterFromBrigade(brigadeId, userId);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Get all brigades", description = "Retrieve a list of all brigades (admin only)")
    @GetMapping("/all")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public List<BrigadeDto> getAllBrigades() {
        return brigadeService.getAllBrigades();
    }

    @Operation(summary = "Get my brigade masters", description = "Retrieve all masters in the authenticated brigadier's brigade")
    @GetMapping("/my/masters")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public List<UserDto> getMyBrigadeMasters(Authentication authentication) {
        return brigadeService.getMyBrigadeMasters(authentication.getName());
    }

    @Operation(summary = "Remove master from my brigade", description = "Remove a master from the authenticated brigadier's brigade")
    @PostMapping("/my/remove-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public ResponseEntity<?> removeMasterFromMyBrigade(@RequestBody Map<String, Long> body, Authentication authentication) {
        Long userId = body.get("userId");
        brigadeService.removeMasterFromMyBrigade(authentication.getName(), userId);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Add master to my brigade", description = "Add a master to the authenticated brigadier's brigade")
    @PostMapping("/my/add-master")
    @PreAuthorize("hasRole('ROLE_BRIGADIER')")
    public ResponseEntity<?> addMasterToMyBrigade(@RequestBody Map<String, Long> body, Authentication authentication) {
        Long userId = body.get("userId");
        brigadeService.addMasterToMyBrigade(authentication.getName(), userId);
        return ResponseEntity.ok().build();
    }
}
