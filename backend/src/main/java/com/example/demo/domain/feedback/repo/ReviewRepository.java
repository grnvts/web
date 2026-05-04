package com.example.demo.domain.feedback.repo;

import com.example.demo.domain.feedback.model.Review;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    @EntityGraph(attributePaths = {"author", "targetUser", "ratings", "ratings.category"})
    List<Review> findByOrderIdOrderByCreatedAtDesc(Long orderId);

    @EntityGraph(attributePaths = {"author", "targetUser", "ratings", "ratings.category"})
    List<Review> findByTargetUserIdOrderByCreatedAtDesc(Long targetUserId);

    @EntityGraph(attributePaths = {"author", "targetUser", "ratings", "ratings.category"})
    List<Review> findByAuthorIdOrderByCreatedAtDesc(Long authorId);

    Optional<Review> findByOrderIdAndAuthorIdAndTargetUserId(Long orderId, Long authorId, Long targetUserId);
}
