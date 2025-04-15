package com.example.demo.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class OrderDto {
    private Long id;
    private Long clientId;
    private String clientUsername;
    private Long brigadierId;
    private String brigadierUsername;
    private Long buildingId;
    private String orderDetails;
    private LocalDateTime createdDate;
    private String status;
    private BigDecimal price;
    private LocalDate startDate;
    private LocalDate endDate;
}
