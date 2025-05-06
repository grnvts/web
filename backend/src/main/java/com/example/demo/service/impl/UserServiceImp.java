package com.example.demo.service.impl;

import java.io.IOException;
import java.util.*;

import java.util.stream.Collectors;

import javax.transaction.Transactional;
import javax.validation.Valid;

import com.example.demo.dto.CreateMasterDto;
import com.example.demo.model.*;
import com.example.demo.repo.BrigadeRepository;
import com.example.demo.repo.QualificationRepository;
import com.example.demo.repo.RoleRepository;
import com.example.demo.service.UserService;
import org.modelmapper.ModelMapper;
import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.demo.dto.UploadImageDto;
import com.example.demo.dto.UserDto;
import com.example.demo.dto.UserUpdateDto;
import com.example.demo.error.ApiError;
import com.example.demo.error.NotFoundException;
import com.example.demo.file.FileService;
import com.example.demo.jwt.config.JwtTokenUtil;
import com.example.demo.repo.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserServiceImp implements UserService {
	public static final String TOKEN_PREFIX = "Bearer ";
	private final UserRepository repository;
	private final ModelMapper mapper;
	private final Logger logger;
	private final PasswordEncoder passwordEncoder;
	private final JwtTokenUtil tokenUtil;
	private final FileService fileService;
	private final RoleRepository roleRepository;
	private final UserRepository userRepository;
	private final QualificationRepository qualificationRepository;
	private String[] types = { "image/png", "image/jpeg" };
	@Autowired
	private BrigadeRepository brigadeRepository;


	@Override
	@Transactional
	public Page<UserDto> getAll(Pageable page, String authHeader) {
		Page<UserDto> pageDto = null;
		if (authHeader != null && authHeader.startsWith(TOKEN_PREFIX)) {
			String username = getUsernameFromToken(authHeader);
			Page<User> pdoUser = repository.findByUsernameNot(username, page);
			pageDto = pdoUser.map(UserDto::new);
			return pageDto;
		}
		// Page<User> pageList = repository.findAll(page).map(UserDto::new);
		pageDto = repository.findAll(page).map(UserDto::new);
		return pageDto;
	}

	@Transactional
	public ResponseEntity<?> save(@Valid User user) {
		//
		if (!user.getPassword().equals(user.getRepeatPassword())) {
			HashMap<String, String> map = new HashMap<>();
			map.put("repeatPassword", "Passwords must be same.");
			ApiError error = new ApiError(400, "Validation Error", null);
			error.setValidationErrors(map);
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
		}

		// User user = mapper.map(dto, User.class);
		user.setCreatedDate(new Date());
		user.setStatus(1);
		user.setRealPassword(user.getPassword());

		user.setPassword(passwordEncoder.encode(user.getRealPassword()));
		if (user.getPatronymic() == null)
			user.setPatronymic("");
		if (user.getPhone() == null)
			user.setPhone("");

		Role role = roleRepository.findByName(RoleName.ROLE_USER)
				.orElseThrow(() -> new IllegalStateException("ROLE_USER not found in DB"));

		user.getRoles().add(role); // ← теперь это уже существующий объект

		user = repository.save(user);
		logger.info("User is saved");

		UserDto dto = mapper.map(user, UserDto.class);
		return ResponseEntity.ok(dto);
	}

	@Transactional
	public UserDto getUser(String username) {
		User user = repository.findUserByUsernameWithStatusOne(username);

		if (user == null) {
			logger.error("There is no user with " + username);
			throw new NotFoundException();
			// throw new IllegalArgumentException("There is no user with " + id);
		}
		logger.info("User is ok");
		UserDto dto = mapper.map(user, UserDto.class);
		return dto;
	}

	@Override
	public Boolean deleteUser(Long id) {
		User user = repository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("There is no user with id: " + id));
		user.setStatus(0); // Помечаем как неактивного
		repository.save(user);
		return true;
	}


	private String getUsernameFromToken(String authHeader) {

		String username = null;
		if (authHeader != null && authHeader.startsWith(TOKEN_PREFIX)) {
			String token = authHeader.replace(TOKEN_PREFIX, "");
			username = tokenUtil.getUsernameFromToken(token);
		}
		return username;
	}

	@Override
	@Transactional
	public ResponseEntity<?> updateUser(String authHeader, String username, UserUpdateDto dto) {
		String userNameFromToken = getUsernameFromToken(authHeader);

		// Админ может редактировать другого пользователя
		boolean isAdmin = false;
		User adminUser = repository.findUserByUsernameWithStatusOne(userNameFromToken);
		if (adminUser != null
				&& adminUser.getRoles().stream().anyMatch(role -> role.getName().name().equals("ROLE_ADMIN"))) {
			isAdmin = true;
		}

		// Если не админ, но пытается редактировать не себя — ошибка
		if (!isAdmin && !userNameFromToken.equals(username)) {
			logger.error("User {} attempted to update user {} but is not allowed", userNameFromToken, username);
			ApiError error = new ApiError(403, "You are not authorized to update this user", "/api/user/" + username);
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
		}

		User user = repository.findUserByUsernameWithStatusOne(username);
		if (user == null) {
			logger.error("No user found with username {}", username);
			throw new NotFoundException();
		}

		// Логирование входных данных
		logger.info("Updating user: {}, current ID: {}", username, user.getId());
		logger.info("Incoming data: email={}, name={}, surname={}", dto.getEmail(), dto.getName(), dto.getSurname());

		// Проверка email на уникальность, если он изменился
		if (dto.getEmail() != null && !dto.getEmail().equals(user.getEmail())) {
			User userWithEmail = repository.findByEmail(dto.getEmail());

			if (userWithEmail != null && !userWithEmail.getId().equals(user.getId())) {
				logger.warn("Email {} already in use by another user", dto.getEmail());
				ApiError error = new ApiError(400, "Email already exists", "/api/user/" + username);
				return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
			}

			user.setEmail(dto.getEmail());
		}

		// Обновление остальных полей
		user.setName(dto.getName());
		user.setSurname(dto.getSurname());
		user.setPatronymic(dto.getPatronymic());
		user.setPhone(dto.getPhone());

		// Обновление username только если пользователь редактирует сам себя
		if (!isAdmin || userNameFromToken.equals(username)) {
			user.setUsername(dto.getUsername());
		}

		user.setBornDate(dto.getBornDate());

		// Сохраняем
		user = repository.save(user);

		logger.info("User {} updated successfully", user.getUsername());
		UserDto result = mapper.map(user, UserDto.class);
		return ResponseEntity.ok(result);
	}

	public ResponseEntity<?> uploadImage(String authHeader, String username, UploadImageDto dto) {
		String userNameFromToken = getUsernameFromToken(authHeader);
		if (!userNameFromToken.equals(username)) {
			logger.error("User Names cannot match");
			ApiError error = new ApiError(403, "User Names cannot match", "api/user/" + authHeader);
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
		}
		User user = repository.findUserByUsernameWithStatusOne(username);
		if (user == null) {
			logger.error("There is no user with " + username);
			throw new NotFoundException();
			// throw new IllegalArgumentException("There is no user with " + id);
		}
		if (dto.getImage() != null) {
			String oldImage = user.getImage();
			try {
				if (!fileService.isValidFileType(types, dto.getImage())) {
					ApiError error = new ApiError(400, "Неверный формат файла", "api/user/upload-image/" + authHeader);
					return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
				}
				String fileName = fileService.writeBase64StringToFile(dto.getImage());
				user.setImage(fileName);
			} catch (IOException e) {
				e.printStackTrace();
			}
			fileService.deleteFile(oldImage);
		}
		user = repository.save(user);
		UserDto result = mapper.map(user, UserDto.class);
		logger.info("Image updated");
		return ResponseEntity.ok(result);
	}
	@Override
	public Boolean restoreUser(Long id) {
		User user = repository.findById(id)
				.orElseThrow(() -> new IllegalArgumentException("There is no user with id: " + id));
		user.setStatus(1); // Восстанавливаем пользователя
		repository.save(user);
		return true;
	}
	@Override
	@Transactional
	public ResponseEntity<?> createUserWithRoles(UserDto dto) {
		// Проверка на уникальность username и email
		if (repository.findByUsername(dto.getUsername()) != null) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST)
					.body(new ApiError(400, "Username already exists", "/api/user"));
		}
		if (repository.findByEmail(dto.getEmail()) != null) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST)
					.body(new ApiError(400, "Email already exists", "/api/user"));
		}

		// Создание нового пользователя
		User user = new User();
		user.setUsername(dto.getUsername());
		user.setPassword(passwordEncoder.encode(dto.getPassword()));
		user.setEmail(dto.getEmail());
		user.setName(dto.getName());
		user.setSurname(dto.getSurname());
		user.setPatronymic(dto.getPatronymic());
		user.setPhone(dto.getPhone());
		user.setBornDate(dto.getBornDate());
		user.setCreatedDate(new Date());
		user.setStatus(1); // Активный статус

		// Присваивание ролей
		Set<Role> roles = dto.getRoles().stream()
				.map(roleName -> roleRepository.findByName(RoleName.valueOf(roleName))
						.orElseThrow(() -> new IllegalArgumentException("Role not found: " + roleName)))
				.collect(Collectors.toSet());
		user.setRoles(roles);

		// Сохраняем пользователя
		user = repository.save(user);

		boolean isBrigadier = roles.stream()
				.anyMatch(role -> role.getName().equals(RoleName.ROLE_BRIGADIER));
		if (isBrigadier) {
			createBrigadeForBrigadier(user);
		}

		return ResponseEntity.ok(new UserDto(user));
	}


	private void createBrigadeForBrigadier(User brigadier) {
		Brigade brigade = new Brigade();
		brigade.setBrigadier(brigadier);
		brigade.setNumber(brigadier.getId().toString()); // Например: "BR-17"
		brigade.setMasters(List.of()); // Изначально без мастеров
		brigadeRepository.save(brigade);
	}


	@Override
	public User getUserEntity(String username) {
		return userRepository.findUserByUsername(username)
				.orElseThrow(() -> new RuntimeException("User not found"));
	}

	@Override
	public List<UserDto> findAllMasters() {
		List<User> masters = userRepository.findAll().stream()
				.filter(user -> user.getRoles().stream()
						.anyMatch(role -> role.getName().name().equals("ROLE_MASTER")))
				.collect(Collectors.toList());
		return masters.stream().map(UserDto::new).collect(Collectors.toList());
	}


	@Override
	@Transactional
	public ResponseEntity<?> createMaster(CreateMasterDto dto) {
		if (dto.getName() == null || dto.getName().isBlank() ||
				dto.getSurname() == null || dto.getSurname().isBlank() ||
				dto.getPatronymic() == null || dto.getPatronymic().isBlank() ||
				dto.getQualificationIds() == null || dto.getQualificationIds().isEmpty()) {
			return ResponseEntity.badRequest().body("Все поля обязательны");
		}

		// Генерация уникального username
		String baseUsername = "master";
		int counter = 1;
		String username;
		while (true) {
			username = baseUsername + counter;
			if (userRepository.findByUsername(username) == null) break;
			counter++;
		}

		// Создание пользователя-мастера
		User master = new User();
		master.setUsername(username);
		master.setName(dto.getName());
		master.setSurname(dto.getSurname());
		master.setPatronymic(dto.getPatronymic());
		master.setStatus(1);
		String generatedPassword = "Temporary";//временный пароль
		master.setRealPassword(generatedPassword);
		master.setPassword(passwordEncoder.encode(generatedPassword));
		// Присваиваем роль мастера
		Role masterRole = roleRepository.findByName(RoleName.ROLE_MASTER)
				.orElseThrow(() -> new RuntimeException("ROLE_MASTER not found"));
		master.setRoles(Set.of(masterRole));

		// Привязка квалификаций
		List<Qualification> qualifications = qualificationRepository.findAllById(dto.getQualificationIds());
		master.setQualifications(qualifications);

		userRepository.save(master);
		return ResponseEntity.ok(new UserDto(master));
	}

}