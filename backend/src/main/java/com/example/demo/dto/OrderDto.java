package com.example.demo.dto;

import com.example.demo.model.Brigade;
import com.example.demo.model.Order;
import com.example.demo.model.OrderStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.sql.rowset.BaseRowSet;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
@AllArgsConstructor
@NoArgsConstructor
@Data
public class OrderDto {
    private Long id;
    private Long clientId;
    private String clientUsername;
    private String clientName;
    private String clientSurname;
    private String clientPhone;
    private String clientPatronymic;
    private Long brigadierId;
    private String brigadierUsername;
    private String brigadierName;
    private String brigadierSurname;
    private String brigadierPatronymic;
    private String brigadierPhone;
    private String brigadeNumber;
    private Long brigadeId;
   // private List<UserDto> assignedMasters;
    private AddressDto address;
    private Long addressId;
    private String orderDetails;
    private LocalDateTime createdDate;
    private OrderStatus status;
    private String serviceType;
    private BigDecimal price;
    private LocalDate startDate;
    private LocalDate endDate;


    // Конструктор из Order
    public OrderDto(Order order) {
        this.id = order.getId();
        if (order.getClient() != null) {
            this.clientId = order.getClient().getId();
            this.clientUsername = order.getClient().getUsername();
            this.clientName = order.getClient().getName();
            this.clientSurname = order.getClient().getSurname();
            this.clientPhone = order.getClient().getPhone();
            this.clientPatronymic = order.getClient().getPatronymic();
        }
        if (order.getBrigade() != null) {
            this.brigadeId = order.getBrigade().getId();
            this.brigadeNumber = order.getBrigade().getNumber();
            if (order.getBrigade().getBrigadier() != null) {
                this.brigadierId = order.getBrigade().getBrigadier().getId();
                this.brigadierUsername = order.getBrigade().getBrigadier().getUsername();
                this.brigadierName = order.getBrigade().getBrigadier().getName();
                this.brigadierSurname = order.getBrigade().getBrigadier().getSurname();
                this.brigadierPatronymic = order.getBrigade().getBrigadier().getPatronymic();
                this.brigadierPhone = order.getBrigade().getBrigadier().getPhone();
            }
        }
        if (order.getAddress() != null) {
            this.addressId = order.getAddress().getId();
            this.address = new AddressDto(order.getAddress());
        }
        this.orderDetails = order.getOrderDetails();
        this.createdDate = order.getCreatedDate();
        this.status = order.getStatus();
        this.serviceType = order.getServiceType();
        this.price = order.getPrice();
        this.startDate = order.getStartDate();
        this.endDate = order.getEndDate();
    }
}
