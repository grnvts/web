package com.example.demo.domain.orders.dto;

import java.util.List;
import lombok.Data;

@Data
public class CreateMasterDto {
    private String name;
    private String surname;
    private String patronymic;
    private List<Long> qualificationIds;
}
