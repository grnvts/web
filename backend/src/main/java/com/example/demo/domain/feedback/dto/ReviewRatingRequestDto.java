package com.example.demo.domain.feedback.dto;

import lombok.Data;

@Data
public class ReviewRatingRequestDto {
    private String categoryCode;
    private Short score;
}
