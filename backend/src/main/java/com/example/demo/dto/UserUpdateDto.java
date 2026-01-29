package com.example.demo.dto;

import java.util.Date;

import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;


import com.sun.istack.NotNull;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserUpdateDto {
	private Long id;
	@NotEmpty
	@NotNull
	private String username;
	
	@Pattern(regexp = "^[\\p{L}\\s'-]*$", message = "{validation.name.invalid}")
	private String name;

	@Pattern(regexp = "^[\\p{L}\\s'-]*$", message = "{validation.name.invalid}")
	private String surname;

	@Pattern(regexp = "^[\\p{L}\\s'-]*$", message = "{validation.name.invalid}")
	private String patronymic;

	@Pattern(regexp = "^\\+\\d{11,14}$", message = "{validation.phone.invalid}")
	private String phone;

	@NotEmpty
	@NotNull
	@Size(min = 5, max = 200)
	@Email(message = "{validation.email.invalid}")
	private String email;
	
	private Date bornDate;
	
	//@ProfileImage
	private String image;
	
	private String password;
	private String repeatPassword;

//	public UserUpdateDto(User user) {
//		this.id=user.getId();
//		this.username=user.getUsername();
//		this.name=user.getName();
//		this.surname=user.getSurname();
//		this.email=user.getEmail();
//		this.bornDate=user.getBornDate();
//		this.image=user.getImage();
//	}
}
