package com.example.demo.dto;

import com.example.demo.model.Qualification;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
public class QualificationDto {
    private Long id;
    private String name;
    public QualificationDto(Qualification q) {
        this.id = q.getId();
        this.name = q.getName();
    }
}