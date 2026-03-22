package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.user.ChangePasswordRequest;
import com.he186581.school_app.dto.user.UpdateUserRequest;
import com.he186581.school_app.dto.user.UserResponse;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.exception.BadRequestException;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.UserRepository;
import com.he186581.school_app.service.UserService;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public UserResponse getCurrentUser(String username) {
        return mapToResponse(getEntityByUsername(username));
    }

    @Override
    public java.util.List<UserResponse> getAllUsers() {
        return userRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public UserResponse updateCurrentUser(String username, UpdateUserRequest request) {
        User user = getEntityByUsername(username);
        user.setFullName(request.getFullName());
        user.setPhone(request.getPhone());
        user.setGender(request.getGender());
        user.setDateOfBirth(request.getDateOfBirth());
        user.setAddress(request.getAddress());
        return mapToResponse(userRepository.save(user));
    }

    @Override
    public void changePassword(String username, ChangePasswordRequest request) {
        User user = getEntityByUsername(username);

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new BadRequestException("Mật khẩu cũ không chính xác");
        }

        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BadRequestException("Mật khẩu xác nhận không khớp");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    @Override
    public User getEntityByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy user: " + username));
    }

    private UserResponse mapToResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phone(user.getPhone())
                .gender(user.getGender())
                .dateOfBirth(user.getDateOfBirth())
                .address(user.getAddress())
                .studentCode(user.getStudentCode())
                .teacherCode(user.getTeacherCode())
                .parentCode(user.getParentCode())
                .twoFactorEnabled(user.getTwoFactorEnabled())
                .active(user.getActive())
                .roles(user.getRoles().stream()
                        .map(role -> role.getName().name())
                        .collect(Collectors.toSet()))
                .build();
    }
}
