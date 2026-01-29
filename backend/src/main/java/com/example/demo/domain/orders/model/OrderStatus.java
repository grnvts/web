package com.example.demo.domain.orders.model;

public enum OrderStatus {
    CREATED,     // заказ только создан
    APPROVED,    // одобрен админом
    IN_PROGRESS, // выполняется
    COMPLETED,   // завершён
    REJECTED     // отклонён
}


