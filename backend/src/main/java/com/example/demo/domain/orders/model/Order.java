package com.example.demo.domain.orders.model;

import com.example.demo.domain.users.model.User;
import lombok.*;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "orders")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "client_id", nullable = false)
    private User client;

//    @ManyToOne
//    @JoinColumn(name = "brigadier_id")
//    private User brigadier;



    @Column(name = "service_type", nullable = false)
    private String serviceType;

    @Column(name = "order_details", nullable = false)
    private String orderDetails;

    @Column(name = "created_date")
    private LocalDateTime createdDate = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    private OrderStatus status = OrderStatus.CREATED;

    private BigDecimal price;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @ManyToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "address_id", nullable = false)
    private Address address;

    @ManyToOne
    private Brigade brigade;

    @ManyToMany
    @JoinTable(
            name = "order_masters",
            joinColumns = @JoinColumn(name = "order_id"),
            inverseJoinColumns = @JoinColumn(name = "master_id")
    )
    private List<User> assignedMasters;
}
