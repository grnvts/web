package com.example.demo.domain.orders.port;

import com.example.demo.domain.orders.model.Address;

public interface AddressRepositoryPort {
    Address save(Address address);
}
