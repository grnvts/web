package com.example.demo.domain.notifications.repo;

import com.example.demo.domain.notifications.model.Message;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.users.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findByOrderAndRecipient(Order order, User recipient);
    List<Message> findByOrderAndSender(Order order, User sender);
    List<Message> findByOrder(Order order);
    @Query("SELECT m FROM Message m WHERE m.order = :order AND (m.recipient.username = :recipientUsername OR m.sender.username = :senderUsername)")
    List<Message> findByOrderAndRecipientOrSender(@Param("order") Order order, @Param("recipientUsername") String recipientUsername, @Param("senderUsername") String senderUsername);
    @Query("SELECT m FROM Message m WHERE m.order = :order AND " +
            "((m.sender.username = :user1 AND m.recipient.username = :user2) OR " +
            "(m.sender.username = :user2 AND m.recipient.username = :user1)) " +
            "ORDER BY m.timestamp ASC")
    List<Message> findDialogMessages(@Param("order") Order order,
                                     @Param("user1") String user1,
                                     @Param("user2") String user2);
    @Query("SELECT m FROM Message m WHERE m.order = :order AND " +
            "(m.sender.username = :user OR m.recipient.username = :user) " +
            "ORDER BY m.timestamp ASC")
    List<Message> findAdminUserDialogMessages(@Param("order") Order order,
                                              @Param("user") String user);
}
