package com.example.demo.domain.feedback.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ReviewRatingDto {
    private Long categoryId;
    private String categoryCode;
    private String categoryName;
    private Short score;
}
