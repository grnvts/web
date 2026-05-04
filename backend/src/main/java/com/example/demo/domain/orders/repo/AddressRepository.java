package com.example.demo.domain.orders.repo;

import com.example.demo.domain.orders.model.Address;
import com.example.demo.domain.orders.port.AddressRepositoryPort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AddressRepository extends JpaRepository<Address, Long>, AddressRepositoryPort {
}
