package com.example.demo.domain.feedback.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
public class ReviewDto {
    private Long id;
    private Long orderId;
    private Long authorId;
    private String authorUsername;
    private Long targetUserId;
    private String targetUsername;
    private String title;
    private String comment;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Double averageScore;
    private List<ReviewRatingDto> ratings;
}
