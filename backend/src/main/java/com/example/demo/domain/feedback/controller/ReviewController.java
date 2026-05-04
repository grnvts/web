package com.example.demo.domain.feedback.controller;

import com.example.demo.domain.common.config.jwt.JwtUserDetails;
import com.example.demo.domain.feedback.dto.CreateReviewRequestDto;
import com.example.demo.domain.feedback.dto.ReviewDto;
import com.example.demo.domain.feedback.dto.ReviewRatingDto;
import com.example.demo.domain.feedback.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping("/categories")
    public ResponseEntity<List<ReviewRatingDto>> getRatingCategories() {
        return ResponseEntity.ok(reviewService.getRatingCategories());
    }

    @PostMapping("/orders/{orderId}")
    public ResponseEntity<ReviewDto> createReview(
            @PathVariable Long orderId,
            @RequestBody CreateReviewRequestDto request,
            @AuthenticationPrincipal JwtUserDetails user) {
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        ReviewDto created = reviewService.createReview(orderId, user.getUsername(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/orders/{orderId}")
    public ResponseEntity<List<ReviewDto>> getOrderReviews(@PathVariable Long orderId) {
        return ResponseEntity.ok(reviewService.getOrderReviews(orderId));
    }

    @GetMapping("/target/{userId}")
    public ResponseEntity<List<ReviewDto>> getTargetUserReviews(@PathVariable Long userId) {
        return ResponseEntity.ok(reviewService.getReviewsForTargetUser(userId));
    }

    @GetMapping("/my-authored")
    public ResponseEntity<List<ReviewDto>> getMyAuthoredReviews(
            @AuthenticationPrincipal JwtUserDetails user) {
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        return ResponseEntity.ok(reviewService.getAuthoredReviews(user.getUsername()));
    }
}
