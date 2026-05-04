package com.example.demo.domain.feedback.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(
        name = "review_ratings",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_review_rating_review_category",
                        columnNames = {"review_id", "category_id"}
                )
        }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewRating {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "review_id", nullable = false)
    private Review review;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private RatingCategory category;

    @Column(name = "score", nullable = false)
    private Short score;
}
