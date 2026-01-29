package com.example.demo.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class QualificationDto {
    private Long id;
    private String name;

    public QualificationDto(Long id, String name) {
        this.id = id;
        this.name = name;
    }
}
