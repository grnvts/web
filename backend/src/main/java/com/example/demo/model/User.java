package com.example.demo.model;

import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.Lob;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "users")
public class User {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY) // Изменено на IDENTITY
	private Long id;

	// Изменяем имя столбца с uname на username (или наоборот в БД)
	@Column(name = "username", nullable = false, length = 200, unique = true)
	@NotEmpty
	@NotNull
	private String username; // Оставляем имя переменной как было

	@Column(name = "name")
	@Pattern(regexp = "^[\\p{L}\\s'-]*$", message = "{validation.name.invalid}")
	private String name;

	@Column(name = "surname")
	@Pattern(regexp = "^[\\p{L}\\s'-]*$", message = "{validation.name.invalid}")
	private String surname;

    @Column(name = "password_hash")
    @NotEmpty
    @NotNull
    @Size(min = 8)
	//обязательно содержит большую маленькую букву
	@Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*$", message = "{message.username.pattern}")
	private String password;

	@Transient
	private String realPassword;

	@Column(name = "patronymic")
	@Pattern(regexp = "^[\\p{L}\\s'-]*$", message = "{validation.name.invalid}")
	private String patronymic;

	@Column(name = "phone", length = 20)
	@Pattern(regexp = "^\\+\\d{11,14}$", message = "{validation.phone.invalid}")
	private String phone;


	@Column(name = "email", unique = true)
	@NotEmpty
	@NotNull
	@Size(min = 5, max = 200)
	@Email(message = "{validation.email.invalid}")
	private String email;

	private String image;

	@Transient
	private String repeatPassword;

	@Column(name = "born_date")
	private Date bornDate;

	@Column(name = "created_at")
	private Date createdDate;

	@Column(name = "status")
	private Integer status;

	@ManyToMany(fetch = FetchType.EAGER)
	@JoinTable(name = "user_roles",
			joinColumns = @JoinColumn(name = "user_id"),
			inverseJoinColumns = @JoinColumn(name = "role_id"))
	private Set<Role> roles = new HashSet<>();

	@ManyToMany
	@JoinTable(
			name = "master_qualification",
			joinColumns = @JoinColumn(name = "user_id"),
			inverseJoinColumns = @JoinColumn(name = "qualification_id")
	)

	private List<Qualification> qualifications;

}
