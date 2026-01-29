package com.example.demo.model;

import jakarta.persistence.*;

import org.hibernate.annotations.NaturalId;

import lombok.Data;

@Entity
@Table(name = "roles")
@Data
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @NaturalId
    @Column(length = 60, unique = true)
    private RoleName name;


    public Role() {}

    public Role(RoleName name) {
        this.name = name;
    }
}
