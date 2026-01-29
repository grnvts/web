package com.example.demo.service.impl;

import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import jakarta.transaction.Transactional;
import jakarta.validation.Valid;

import com.example.demo.dto.CreateMasterDto;
import com.example.demo.error.BadRequestException;
import com.example.demo.error.ForbiddenException;
import com.example.demo.model.*;
import com.example.demo.repo.BrigadeRepository;
import com.example.demo.repo.QualificationRepository;
import com.example.demo.repo.RoleRepository;
import com.example.demo.service.UserService;
import org.modelmapper.ModelMapper;
import org.slf4j.Logger;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.demo.dto.UploadImageDto;
import com.example.demo.dto.UserDto;
import com.example.demo.dto.UserUpdateDto;
import com.example.demo.error.NotFoundException;
import com.example.demo.file.FileService;
import com.example.demo.repo.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserServiceImp implements UserService {
    private final UserRepository repository;
    private final ModelMapper mapper;
    private final Logger logger;
    private final PasswordEncoder passwordEncoder;
    private final FileService fileService;
    private final RoleRepository roleRepository;
    private final QualificationRepository qualificationRepository;
    private final BrigadeRepository brigadeRepository;

    private final String[] allowedImageTypes = {"image/png", "image/jpeg"};

    @Override
    @Transactional
    public Page<UserDto> getAll(Pageable page, String currentUsername) {
        if (currentUsername != null && !currentUsername.isBlank()) {
            return repository.findByUsernameNot(currentUsername, page).map(UserDto::new);
        }
        return repository.findAll(page).map(UserDto::new);
    }

    @Override
    @Transactional
    public UserDto save(@Valid User user) {
        if (!user.getPassword().equals(user.getRepeatPassword())) {
            throw new BadRequestException("Passwords must be same.");
        }
        ensureUniqueUsername(user.getUsername(), null);
        ensureUniqueEmail(user.getEmail(), null);

        user.setCreatedDate(new Date());
        user.setStatus(1);
        user.setRealPassword(user.getPassword());
        user.setPassword(passwordEncoder.encode(user.getRealPassword()));
        if (user.getPatronymic() == null) user.setPatronymic("");
        if (user.getPhone() == null) user.setPhone("");

        Role roleUser = roleRepository.findByName(RoleName.ROLE_USER)
                .orElseThrow(() -> new IllegalStateException("ROLE_USER not found in DB"));
        user.getRoles().add(roleUser);

        User saved = repository.save(user);
        logger.info("User {} saved", saved.getUsername());
        return mapper.map(saved, UserDto.class);
    }

    @Transactional
    public UserDto getUser(String username) {
        User user = repository.findUserByUsernameWithStatusOne(username);
        if (user == null) {
            logger.error("No user with username {}", username);
            throw new NotFoundException();
        }
        return mapper.map(user, UserDto.class);
    }

    @Override
    @Transactional
    public void deleteUser(Long id) {
        User user = repository.findById(id)
                .orElseThrow(NotFoundException::new);
        user.setStatus(0);
        repository.save(user);
    }

    @Override
    @Transactional
    public UserDto updateUser(String requester, String username, UserUpdateDto dto) {
        User requesterUser = repository.findUserByUsernameWithStatusOne(requester);
        if (requesterUser == null) throw new ForbiddenException("Unknown requester");

        boolean isAdmin = requesterUser.getRoles().stream()
                .anyMatch(role -> role.getName().equals(RoleName.ROLE_ADMIN));
        if (!isAdmin && !requester.equals(username)) {
            logger.error("User {} attempted to update {}", requester, username);
            throw new ForbiddenException("You are not authorized to update this user");
        }

        User user = repository.findUserByUsernameWithStatusOne(username);
        if (user == null) throw new NotFoundException();

        if (dto.getPassword() != null && !dto.getPassword().trim().isEmpty()) {
            if (dto.getRepeatPassword() == null || !dto.getPassword().equals(dto.getRepeatPassword())) {
                throw new BadRequestException("Passwords must be same.");
            }
            user.setRealPassword(dto.getPassword());
            user.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        if (dto.getUsername() != null && !dto.getUsername().equals(user.getUsername())) {
            ensureUniqueUsername(dto.getUsername(), user.getId());
            user.setUsername(dto.getUsername());
        }

        if (dto.getEmail() != null && !dto.getEmail().equals(user.getEmail())) {
            ensureUniqueEmail(dto.getEmail(), user.getId());
            user.setEmail(dto.getEmail());
        }

        user.setName(dto.getName());
        user.setSurname(dto.getSurname());
        user.setPatronymic(dto.getPatronymic());
        user.setPhone(dto.getPhone());
        user.setBornDate(dto.getBornDate());

        User saved = repository.save(user);
        return mapper.map(saved, UserDto.class);
    }

    @Override
    @Transactional
    public UserDto uploadImage(String requester, String username, UploadImageDto dto) {
        if (!requester.equals(username)) {
            throw new ForbiddenException("You are not authorized to update this image");
        }
        User user = repository.findUserByUsernameWithStatusOne(username);
        if (user == null) throw new NotFoundException();

        if (dto.getImage() != null) {
            String oldImage = user.getImage();
            if (!fileService.isValidFileType(allowedImageTypes, dto.getImage())) {
                throw new BadRequestException("Неверный формат файла");
            }
            try {
                String fileName = fileService.writeBase64StringToFile(dto.getImage());
                user.setImage(fileName);
                fileService.deleteFile(oldImage);
            } catch (IOException e) {
                throw new RuntimeException("Unable to store image", e);
            }
        }
        User saved = repository.save(user);
        return mapper.map(saved, UserDto.class);
    }

    @Override
    @Transactional
    public void restoreUser(Long id) {
        User user = repository.findById(id)
                .orElseThrow(NotFoundException::new);
        user.setStatus(1);
        repository.save(user);
    }

    @Override
    @Transactional
    public UserDto createUserWithRoles(UserDto dto) {
        if (dto.getPassword() == null || dto.getPassword().isBlank()) {
            throw new BadRequestException("Password is required");
        }
        ensureUniqueUsername(dto.getUsername(), null);
        ensureUniqueEmail(dto.getEmail(), null);

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
        user.setStatus(1);

        Set<Role> roles = dto.getRoles().stream()
                .map(roleName -> roleRepository.findByName(RoleName.valueOf(roleName))
                        .orElseThrow(() -> new IllegalArgumentException("Role not found: " + roleName)))
                .collect(Collectors.toSet());
        user.setRoles(roles);

        User saved = repository.save(user);

        boolean isBrigadier = roles.stream()
                .anyMatch(role -> role.getName().equals(RoleName.ROLE_BRIGADIER));
        if (isBrigadier) {
            createBrigadeForBrigadier(saved);
        }
        return new UserDto(saved);
    }

    private void createBrigadeForBrigadier(User brigadier) {
        Brigade brigade = new Brigade();
        brigade.setBrigadier(brigadier);
        brigade.setNumber(brigadier.getId().toString());
        brigade.setMasters(List.of());
        brigadeRepository.save(brigade);
    }

    @Override
    public User getUserEntity(String username) {
        return repository.findUserByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public List<UserDto> findAllMasters() {
        return repository.findAll().stream()
                .filter(user -> user.getRoles().stream()
                        .anyMatch(role -> role.getName().equals(RoleName.ROLE_MASTER)))
                .map(UserDto::new)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public UserDto createMaster(CreateMasterDto dto) {
        if (dto.getName() == null || dto.getName().isBlank() ||
                dto.getSurname() == null || dto.getSurname().isBlank() ||
                dto.getPatronymic() == null || dto.getPatronymic().isBlank() ||
                dto.getQualificationIds() == null || dto.getQualificationIds().isEmpty()) {
            throw new BadRequestException("Все поля обязательны");
        }

        String username = generateUniqueMasterUsername();

        User master = new User();
        master.setUsername(username);
        master.setName(dto.getName());
        master.setSurname(dto.getSurname());
        master.setPatronymic(dto.getPatronymic());
        master.setStatus(1);
        String generatedPassword = "Temporary";
        master.setRealPassword(generatedPassword);
        master.setPassword(passwordEncoder.encode(generatedPassword));

        Role masterRole = roleRepository.findByName(RoleName.ROLE_MASTER)
                .orElseThrow(() -> new RuntimeException("ROLE_MASTER not found"));
        master.setRoles(Set.of(masterRole));

        List<Qualification> qualifications = qualificationRepository.findAllById(dto.getQualificationIds());
        master.setQualifications(qualifications);

        User saved = repository.save(master);
        return new UserDto(saved);
    }

    private String generateUniqueMasterUsername() {
        String baseUsername = "master";
        int counter = 1;
        String username;
        while (true) {
            username = baseUsername + counter;
            if (repository.findByUsername(username) == null) break;
            counter++;
        }
        return username;
    }

    private void ensureUniqueUsername(String username, Long currentId) {
        User existing = repository.findUserByUsernameWithStatusOne(username);
        if (existing != null && (currentId == null || !existing.getId().equals(currentId))) {
            throw new BadRequestException("Username already exists");
        }
    }

    private void ensureUniqueEmail(String email, Long currentId) {
        User existing = repository.findByEmail(email);
        if (existing != null && (currentId == null || !existing.getId().equals(currentId))) {
            throw new BadRequestException("Email already exists");
        }
    }
}
