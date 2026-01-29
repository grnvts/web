package com.example.demo.domain.orders.model;

import com.example.demo.domain.users.model.User;
import lombok.Getter;
import lombok.Setter;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Getter
@Setter
public class Brigade {
    @Id
    @GeneratedValue
    private Long id;

    @Column(unique = true)
    private String number;

    @OneToOne
    private User brigadier;

    @ManyToMany
    @JoinTable(
            name = "brigade_masters",
            joinColumns = @JoinColumn(name = "brigade_id"),
            inverseJoinColumns = @JoinColumn(name = "master_id")
    )
    private List<User> masters;
}
