package com.example.demo.model;

import javax.persistence.*;

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

    // Удаляем user_id, так как связь многие-ко-многим через user_roles
    // private Long user_id;

    public Role() {}

    public Role(RoleName name) {
        this.name = name;
    }
}