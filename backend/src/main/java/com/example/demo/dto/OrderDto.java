package com.example.demo.dto;

import com.example.demo.model.OrderStatus;
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
    private AddressDto address;
    private Long addressId;
    private String orderDetails;
    private LocalDateTime createdDate;
    private OrderStatus status;
    private String serviceType;
    private BigDecimal price;
    private LocalDate startDate;
    private LocalDate endDate;
}
