package com.example.demo.domain.orders.repo;

import com.example.demo.domain.orders.model.Brigade;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByClient(User client);
   // List<Order> findByBrigadier(User brigadier);
    List<Order> findByBrigade(Brigade brigade);
    @Query("SELECT o FROM Order o WHERE o.brigade.brigadier.id = :brigadierId")
    List<Order> findByBrigadierId(@Param("brigadierId") Long brigadierId);
    @Query("SELECT o FROM Order o WHERE o.brigade.brigadier.id = (SELECT u.id FROM User u WHERE u.username = :username)")
    List<Order> findByBrigadierUsername(@Param("username") String username);

    @Query("SELECT o.startDate, COUNT(o) FROM Order o WHERE o.brigade.brigadier.username = :username AND o.startDate BETWEEN :start AND :end GROUP BY o.startDate")
    List<Object[]> countOrdersByBrigadierPerDay(@Param("username") String username, @Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query("SELECT o FROM Order o WHERE (o.endDate >= :currentDate OR o.status = 'IN_PROGRESS' OR o.startDate >= :currentDate) AND o.brigade.brigadier.username = :username")
    List<Order> findActiveOrdersForBrigadier(@Param("username") String username, @Param("currentDate") LocalDate currentDate);

 @Query("SELECT o FROM Order o LEFT JOIN FETCH o.brigade b LEFT JOIN FETCH b.brigadier WHERE o.id = :id")
 Optional<Order> findByIdWithBrigadier(@Param("id") Long id);
}
