package com.example.demo.domain.orders.service;

import com.example.demo.domain.orders.dto.BrigadeDto;
import com.example.demo.domain.users.dto.UserDto;

import java.util.List;

public interface BrigadeService {
    List<UserDto> getBrigadeMasters(Long brigadeId);

    void addMasterToBrigade(Long brigadeId, Long userId);

    void removeMasterFromBrigade(Long brigadeId, Long userId);

    List<BrigadeDto> getAllBrigades();

    List<UserDto> getMyBrigadeMasters(String username);

    void addMasterToMyBrigade(String username, Long userId);

    void removeMasterFromMyBrigade(String username, Long userId);
}
