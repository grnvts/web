package com.example.demo.domain.common.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import org.springframework.beans.factory.annotation.Autowired;

import com.example.demo.domain.users.model.User;
import com.example.demo.domain.users.port.UserAccessPort;

public class UniqueUsernameValidator implements ConstraintValidator<UniqueData, String> {

	@Autowired
	UserAccessPort userAccessPort; 
	
	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		User user = userAccessPort.findByUsername(value);
		if(user != null) return false;
		return true;
	}
 
}
