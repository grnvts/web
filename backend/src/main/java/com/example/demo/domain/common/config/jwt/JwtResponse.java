package com.example.demo.domain.common.config.jwt;

import java.io.Serializable;
import java.util.Set;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class JwtResponse  implements Serializable{
	private String username;
	private String jwttoken;
	private String email;
	private String image;
	private Set<String> roles;
}
