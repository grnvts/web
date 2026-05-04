package com.example.demo.domain.feedback.service;

import com.example.demo.domain.feedback.dto.CreateReviewRequestDto;
import com.example.demo.domain.feedback.dto.ReviewRatingDto;
import com.example.demo.domain.feedback.dto.ReviewDto;

import java.util.List;

public interface ReviewService {
    ReviewDto createReview(Long orderId, String username, CreateReviewRequestDto request);

    List<ReviewDto> getOrderReviews(Long orderId);

    List<ReviewDto> getReviewsForTargetUser(Long userId);

    List<ReviewDto> getAuthoredReviews(String username);

    List<ReviewRatingDto> getRatingCategories();
}
