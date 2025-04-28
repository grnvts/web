package com.example.demo.model;

import javax.persistence.*;
import java.util.List;
@Entity
public class Qualification {
    @Id
    @GeneratedValue
    private Long id;

    private String name;

    @ManyToMany(mappedBy = "qualifications")
    private List<User> masters;
}

