package com.example.demo.domain.feedback.repo;

import com.example.demo.domain.feedback.model.RatingCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RatingCategoryRepository extends JpaRepository<RatingCategory, Long> {
    Optional<RatingCategory> findByCode(String code);
}
