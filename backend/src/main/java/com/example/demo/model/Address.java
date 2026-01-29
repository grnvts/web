package com.example.demo.model;

import lombok.*;

import jakarta.persistence.*;

@Entity
@Table(name = "addresses")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Address {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String city;

    @Column(nullable = false)
    private String street;

    @Column(nullable = false)
    private String buildingNo;

    private String apartmentNo;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}

