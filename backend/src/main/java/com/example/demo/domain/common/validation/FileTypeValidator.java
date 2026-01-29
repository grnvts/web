package com.example.demo.domain.common.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import org.springframework.beans.factory.annotation.Autowired;

import com.example.demo.domain.common.util.file.FileService;

public class FileTypeValidator  implements ConstraintValidator<FileType, String>{

	@Autowired
	FileService fileService;
	
	String [] types;
	@Override
	public void initialize(FileType constraintAnnotation) {
		this.types = constraintAnnotation.types();
	}
	
	@Override
	public boolean isValid(String value, ConstraintValidatorContext context) {
		return fileService.isValidFileType(this.types, value);

	}

}
