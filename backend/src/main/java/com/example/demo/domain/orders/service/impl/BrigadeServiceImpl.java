package com.example.demo.domain.orders.service.impl;

import com.example.demo.domain.orders.dto.BrigadeDto;
import com.example.demo.domain.orders.model.Brigade;
import com.example.demo.domain.orders.port.BrigadeRepositoryPort;
import com.example.demo.domain.orders.service.BrigadeService;
import com.example.demo.domain.users.dto.UserDto;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BrigadeServiceImpl implements BrigadeService {

    private final BrigadeRepositoryPort brigadeRepository;
    private final UserAccessPort userAccessPort;

    @Override
    public List<UserDto> getBrigadeMasters(Long brigadeId) {
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        return brigade.getMasters().stream()
                .map(UserDto::new)
                .collect(Collectors.toList());
    }

    @Override
    public void addMasterToBrigade(Long brigadeId, Long userId) {
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        User master = userAccessPort.findById(userId);
        if (master == null) throw new RuntimeException("User not found");
        if (!brigade.getMasters().contains(master)) {
            brigade.getMasters().add(master);
            brigadeRepository.save(brigade);
        }
    }

    @Override
    public void removeMasterFromBrigade(Long brigadeId, Long userId) {
        Brigade brigade = brigadeRepository.findById(brigadeId).orElseThrow();
        User master = userAccessPort.findById(userId);
        if (master == null) throw new RuntimeException("User not found");
        brigade.getMasters().remove(master);
        brigadeRepository.save(brigade);
    }

    @Override
    public List<BrigadeDto> getAllBrigades() {
        return brigadeRepository.findAll().stream()
                .map(BrigadeDto::new)
                .collect(Collectors.toList());
    }

    @Override
    public List<UserDto> getMyBrigadeMasters(String username) {
        User brigadier = userAccessPort.findByUsername(username);
        if (brigadier == null) throw new RuntimeException("User not found");
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));
        return brigade.getMasters().stream()
                .map(UserDto::new)
                .collect(Collectors.toList());
    }

    @Override
    public void addMasterToMyBrigade(String username, Long userId) {
        User brigadier = userAccessPort.findByUsername(username);
        if (brigadier == null) throw new RuntimeException("User not found");
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));
        User master = userAccessPort.findById(userId);
        if (master == null) throw new RuntimeException("User not found");
        if (!brigade.getMasters().contains(master)) {
            brigade.getMasters().add(master);
            brigadeRepository.save(brigade);
        }
    }

    @Override
    public void removeMasterFromMyBrigade(String username, Long userId) {
        User brigadier = userAccessPort.findByUsername(username);
        if (brigadier == null) throw new RuntimeException("User not found");
        Brigade brigade = brigadeRepository.findByBrigadier(brigadier)
                .orElseThrow(() -> new RuntimeException("Brigade not found for brigadier"));
        User master = userAccessPort.findById(userId);
        if (master == null) throw new RuntimeException("User not found");
        brigade.getMasters().remove(master);
        brigadeRepository.save(brigade);
    }
}
