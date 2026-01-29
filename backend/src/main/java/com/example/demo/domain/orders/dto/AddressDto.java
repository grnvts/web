package com.example.demo.domain.orders.dto;


import com.example.demo.domain.orders.model.Address;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class AddressDto {
    private Long id;
    private String city;
    private String street;
    private String buildingNo;
    private String apartmentNo;
    public AddressDto(Address address) {
        this.id = address.getId();
        this.city = address.getCity();
        this.street = address.getStreet();
        this.buildingNo = address.getBuildingNo();
        this.apartmentNo = address.getApartmentNo();
    }
}
