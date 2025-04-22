package com.example.demo.dto;

import java.util.Date;
import java.util.Set;
import java.util.stream.Collectors;

import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Lob;

import com.example.demo.model.User;
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
public class UserDto {
	private Long id;
	
	private String username;
	
	private String name;
	
	private String surname;
	private String patronymic;
	private String phone;
	private String email;

	private String repeatPassword;
	private String Password;

	private Date bornDate;
	private Date createdDate;
	private int status;
	private String image;
	private Set<String> roles;


	
	public String getFullName() {
		return this.name+" "+this.surname+" "+this.patronymic;
	}
	public UserDto(User user) {
		this.id=user.getId();
		this.username=user.getUsername();
		this.name=user.getName();
		this.surname=user.getSurname();
		this.patronymic=user.getPatronymic();
		this.phone=user.getPhone();
		this.email=user.getEmail();
		this.bornDate=user.getBornDate();
		this.createdDate=user.getCreatedDate();
		this.image=user.getImage();
		this.status=user.getStatus();
		this.roles = user.getRoles().stream()
				.map(role -> role.getName().name())
				.collect(Collectors.toSet());
	}
}
