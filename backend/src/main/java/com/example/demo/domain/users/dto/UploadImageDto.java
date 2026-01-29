package com.example.demo.domain.users.dto;

import com.example.demo.domain.common.validation.FileType;

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
public class UploadImageDto {

	@FileType(types = {"image/png","image/jpeg"} )
	String image;
}
