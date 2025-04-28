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
    private String clientName;
    private String clientSurname;
    private String clientPhone;
    private String clientPatronymic;
    private Long brigadierId;
    private String brigadierUsername;
    private String brigadierName;
    private String brigadierSurname;
    private String brigadierPatronymic;
    private String brigadierPhone;
    private String brigadeNumber;
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
