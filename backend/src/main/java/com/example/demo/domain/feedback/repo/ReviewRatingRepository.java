package com.example.demo.domain.feedback.repo;

import com.example.demo.domain.feedback.model.ReviewRating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReviewRatingRepository extends JpaRepository<ReviewRating, Long> {
}
