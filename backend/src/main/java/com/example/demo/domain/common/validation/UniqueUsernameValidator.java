package com.example.demo.domain.common.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import org.springframework.beans.factory.annotation.Autowired;

import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.repo.UserRepository;

public class UniqueUsernameValidator implements ConstraintValidator<UniqueData, String> {

	@Autowired
	UserRepository repository; 
	
	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		User user = repository.findByUsername(value);
		if(user != null) return false;
		return true;
	}
 
}
