package com.example.demo.model;

import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.Lob;
import javax.persistence.ManyToMany;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.Transient;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;


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
