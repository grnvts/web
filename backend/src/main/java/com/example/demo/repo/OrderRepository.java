package com.example.demo.repo;

import com.example.demo.model.Order;
import com.example.demo.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByClient(User client);
    List<Order> findByBrigadier(User brigadier);
    @Query("SELECT o FROM Order o WHERE o.brigadier.id = :brigadierId")
    List<Order> findByBrigadierId(@Param("brigadierId") Long brigadierId);
    @Query("SELECT o FROM Order o WHERE o.brigadier.id = (SELECT u.id FROM User u WHERE u.username = :username)")
    List<Order> findByBrigadierUsername(@Param("username") String username);

    @Query("SELECT o.startDate, COUNT(o) FROM Order o WHERE o.brigadier.username = :username AND o.startDate BETWEEN :start AND :end GROUP BY o.startDate")
    List<Object[]> countOrdersByBrigadierPerDay(@Param("username") String username, @Param("start") LocalDate start, @Param("end") LocalDate end);

}
