package com.example.demo.dto;

import com.example.demo.model.Brigade;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.stream.Collectors;

@Getter
@Setter
public class BrigadeDto {
    private Long id;
    private String number;
    private UserDto brigadier;
    private List<UserDto> masters;

    public BrigadeDto(Brigade brigade) {
        this.id = brigade.getId();
        this.number = brigade.getNumber();
        this.brigadier = new UserDto(brigade.getBrigadier());
        this.masters = brigade.getMasters().stream()
                .map(UserDto::new)
                .collect(Collectors.toList());
    }
} 
