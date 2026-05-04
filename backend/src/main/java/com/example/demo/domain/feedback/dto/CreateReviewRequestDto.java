package com.example.demo.domain.feedback.dto;

import lombok.Data;

import java.util.List;

@Data
public class CreateReviewRequestDto {
    private Long targetUserId;
    private String title;
    private String comment;
    private List<ReviewRatingRequestDto> ratings;
}
