package com.example.demo.model;

import lombok.Getter;
import lombok.Setter;

import jakarta.persistence.*;
import java.util.List;
@Entity
@Getter
@Setter
public class Qualification {
    @Id
    @GeneratedValue
    private Long id;

    private String name;

    @ManyToMany(mappedBy = "qualifications")
    private List<User> masters;
}

