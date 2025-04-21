package com.example.demo.dto;


import lombok.Data;

@Data
public class AddressDto {
    private Long id;
    private String city;
    private String street;
    private String buildingNo;
    private String apartmentNo;
}
