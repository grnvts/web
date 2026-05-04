package com.example.demo.domain.feedback.service.impl;

import com.example.demo.domain.common.error.BadRequestException;
import com.example.demo.domain.common.error.NotFoundException;
import com.example.demo.domain.feedback.dto.CreateReviewRequestDto;
import com.example.demo.domain.feedback.dto.ReviewDto;
import com.example.demo.domain.feedback.dto.ReviewRatingDto;
import com.example.demo.domain.feedback.dto.ReviewRatingRequestDto;
import com.example.demo.domain.feedback.model.RatingCategory;
import com.example.demo.domain.feedback.model.Review;
import com.example.demo.domain.feedback.model.ReviewRating;
import com.example.demo.domain.feedback.repo.RatingCategoryRepository;
import com.example.demo.domain.feedback.repo.ReviewRepository;
import com.example.demo.domain.feedback.service.ReviewService;
import com.example.demo.domain.orders.model.Order;
import com.example.demo.domain.orders.service.OrderService;
import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final RatingCategoryRepository ratingCategoryRepository;
    private final UserAccessPort userAccessPort;
    private final OrderService orderService;

    @Override
    @Transactional
    public ReviewDto createReview(Long orderId, String username, CreateReviewRequestDto request) {
        User author = userAccessPort.findActiveByUsername(username);
        Order order = orderService.getOrderEntity(orderId);

        if (!order.getClient().getId().equals(author.getId())) {
            throw new BadRequestException("Only the client can create a review for this order");
        }

        if (request.getTargetUserId() == null) {
            throw new BadRequestException("Target user is required");
        }

        User targetUser = userAccessPort.findById(request.getTargetUserId());
        if (targetUser == null) {
            throw new NotFoundException();
        }

        boolean targetIsAllowed = order.getBrigade() != null
                && order.getBrigade().getBrigadier() != null
                && Objects.equals(order.getBrigade().getBrigadier().getId(), targetUser.getId());

        if (!targetIsAllowed && order.getAssignedMasters() != null) {
            targetIsAllowed = order.getAssignedMasters().stream()
                    .anyMatch(master -> Objects.equals(master.getId(), targetUser.getId()));
        }

        if (!targetIsAllowed) {
            throw new BadRequestException("Target user is not assigned to the order");
        }

        if (reviewRepository.findByOrderIdAndAuthorIdAndTargetUserId(orderId, author.getId(), targetUser.getId()).isPresent()) {
            throw new BadRequestException("Review for this user and order already exists");
        }

        if (request.getRatings() == null || request.getRatings().isEmpty()) {
            throw new BadRequestException("At least one rating is required");
        }

        Review review = new Review();
        review.setOrder(order);
        review.setAuthor(author);
        review.setTargetUser(targetUser);
        review.setTitle(request.getTitle());
        review.setComment(request.getComment());

        for (ReviewRatingRequestDto ratingRequest : request.getRatings()) {
            if (ratingRequest.getCategoryCode() == null || ratingRequest.getScore() == null) {
                throw new BadRequestException("Rating category and score are required");
            }
            if (ratingRequest.getScore() < 1 || ratingRequest.getScore() > 5) {
                throw new BadRequestException("Rating score must be between 1 and 5");
            }

            RatingCategory category = ratingCategoryRepository.findByCode(ratingRequest.getCategoryCode())
                    .orElseThrow(NotFoundException::new);

            ReviewRating reviewRating = new ReviewRating();
            reviewRating.setReview(review);
            reviewRating.setCategory(category);
            reviewRating.setScore(ratingRequest.getScore());
            review.getRatings().add(reviewRating);
        }

        return toDto(reviewRepository.save(review));
    }

    @Override
    public List<ReviewDto> getOrderReviews(Long orderId) {
        return reviewRepository.findByOrderIdOrderByCreatedAtDesc(orderId).stream()
                .map(this::toDto)
                .toList();
    }

    @Override
    public List<ReviewDto> getReviewsForTargetUser(Long userId) {
        return reviewRepository.findByTargetUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toDto)
                .toList();
    }

    @Override
    public List<ReviewDto> getAuthoredReviews(String username) {
        User author = userAccessPort.findActiveByUsername(username);
        return reviewRepository.findByAuthorIdOrderByCreatedAtDesc(author.getId()).stream()
                .map(this::toDto)
                .toList();
    }

    @Override
    public List<ReviewRatingDto> getRatingCategories() {
        return ratingCategoryRepository.findAll().stream()
                .filter(RatingCategory::isActive)
                .map(category -> new ReviewRatingDto(
                        category.getId(),
                        category.getCode(),
                        category.getName(),
                        null
                ))
                .toList();
    }

    private ReviewDto toDto(Review review) {
        List<ReviewRatingDto> ratings = review.getRatings().stream()
                .map(rating -> new ReviewRatingDto(
                        rating.getCategory().getId(),
                        rating.getCategory().getCode(),
                        rating.getCategory().getName(),
                        rating.getScore()
                ))
                .toList();

        double averageScore = review.getRatings().stream()
                .mapToInt(ReviewRating::getScore)
                .average()
                .orElse(0);

        return ReviewDto.builder()
                .id(review.getId())
                .orderId(review.getOrder().getId())
                .authorId(review.getAuthor().getId())
                .authorUsername(review.getAuthor().getUsername())
                .targetUserId(review.getTargetUser() != null ? review.getTargetUser().getId() : null)
                .targetUsername(review.getTargetUser() != null ? review.getTargetUser().getUsername() : null)
                .title(review.getTitle())
                .comment(review.getComment())
                .createdAt(review.getCreatedAt())
                .updatedAt(review.getUpdatedAt())
                .averageScore(averageScore)
                .ratings(ratings)
                .build();
    }
}
