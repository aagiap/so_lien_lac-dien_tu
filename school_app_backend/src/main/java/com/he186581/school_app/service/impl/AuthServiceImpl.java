package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.auth.AuthResponse;
import com.he186581.school_app.dto.auth.EnableTwoFactorRequest;
import com.he186581.school_app.dto.auth.ForgotPasswordRequest;
import com.he186581.school_app.dto.auth.LoginRequest;
import com.he186581.school_app.dto.auth.RefreshTokenRequest;
import com.he186581.school_app.dto.auth.ResetPasswordRequest;
import com.he186581.school_app.dto.auth.TwoFactorSetupResponse;
import com.he186581.school_app.dto.auth.VerifyOtpRequest;
import com.he186581.school_app.dto.user.UserResponse;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.exception.BadRequestException;
import com.he186581.school_app.repository.UserRepository;
import com.he186581.school_app.service.AuthService;
import com.he186581.school_app.service.EmailService;
import com.he186581.school_app.util.JwtUtil;
import com.he186581.school_app.util.TotpUtil;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final TotpUtil totpUtil;
    private final EmailService emailService;

    @Value("${app.frontend-reset-url}")
    private String frontendResetUrl;

    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByPhone(request.getPhone())
                .orElseThrow(() -> new BadRequestException("Số điện thoại không tồn tại"));

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(user.getUsername(), request.getPassword())
        );

        if (Boolean.TRUE.equals(user.getTwoFactorEnabled())) {
            return AuthResponse.builder()
                    .requiresOtp(true)
                    .temporaryToken(jwtUtil.generateOtpToken(user.getUsername()))
                    .tokenType("Bearer")
                    .user(mapToUserResponse(user))
                    .build();
        }

        return buildTokenResponse(user);
    }

    @Override
    public AuthResponse verifyOtp(VerifyOtpRequest request) {
        if (!jwtUtil.isOtpToken(request.getTemporaryToken())) {
            throw new BadRequestException("Temporary token không hợp lệ");
        }

        String username = jwtUtil.extractUsername(request.getTemporaryToken());
        User user = getUserByUsername(username);

        if (user.getTwoFactorSecret() == null || user.getTwoFactorSecret().isBlank()) {
            throw new BadRequestException("Tài khoản chưa cấu hình 2FA");
        }

        boolean validOtp = totpUtil.verifyCode(user.getTwoFactorSecret(), request.getOtp());
        if (!validOtp) {
            throw new BadRequestException("OTP không chính xác hoặc đã hết hạn");
        }

        return buildTokenResponse(user);
    }

    @Override
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        if (!jwtUtil.isRefreshToken(request.getRefreshToken())) {
            throw new BadRequestException("Refresh token không hợp lệ");
        }

        String username = jwtUtil.extractUsername(request.getRefreshToken());
        User user = getUserByUsername(username);

        return buildTokenResponse(user);
    }

    @Override
    public void forgotPassword(ForgotPasswordRequest request) {
        userRepository.findByEmail(request.getEmail()).ifPresent(user -> {
            String resetToken = jwtUtil.generateResetToken(user.getUsername());
            emailService.sendResetPasswordEmail(user.getEmail(), frontendResetUrl + resetToken);
        });
    }

    @Override
    public void resetPassword(ResetPasswordRequest request) {
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BadRequestException("Mật khẩu xác nhận không khớp");
        }

        if (!jwtUtil.isResetToken(request.getToken())) {
            throw new BadRequestException("Reset token không hợp lệ");
        }

        String username = jwtUtil.extractUsername(request.getToken());
        User user = getUserByUsername(username);
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    @Override
    public TwoFactorSetupResponse setup2fa(String username) {
        User user = getUserByUsername(username);

        if (user.getTwoFactorSecret() == null || user.getTwoFactorSecret().isBlank()) {
            user.setTwoFactorSecret(totpUtil.generateSecret());
            userRepository.save(user);
        }

        return TwoFactorSetupResponse.builder()
                .secret(user.getTwoFactorSecret())
                .otpAuthUrl(totpUtil.getOtpAuthUrl(user.getUsername(), user.getTwoFactorSecret()))
                .build();
    }

    @Override
    public void enable2fa(String username, EnableTwoFactorRequest request) {
        User user = getUserByUsername(username);

        if (user.getTwoFactorSecret() == null || user.getTwoFactorSecret().isBlank()) {
            throw new BadRequestException("Bạn cần setup 2FA trước khi bật");
        }

        boolean validOtp = totpUtil.verifyCode(user.getTwoFactorSecret(), request.getOtp());
        if (!validOtp) {
            throw new BadRequestException("OTP xác thực 2FA không chính xác");
        }

        user.setTwoFactorEnabled(true);
        userRepository.save(user);
    }

    @Override
    public void disable2fa(String username) {
        User user = getUserByUsername(username);
        user.setTwoFactorEnabled(false);
        user.setTwoFactorSecret(null);
        userRepository.save(user);
    }

    @Override
    public void logout() {
        // Vì hệ thống dùng JWT stateless nên logout phía server chỉ cần để client xoá token.
    }

    private AuthResponse buildTokenResponse(User user) {
        return AuthResponse.builder()
                .requiresOtp(false)
                .accessToken(jwtUtil.generateAccessToken(user))
                .refreshToken(jwtUtil.generateRefreshToken(user.getUsername()))
                .tokenType("Bearer")
                .user(mapToUserResponse(user))
                .build();
    }

    private User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new BadRequestException("Username không tồn tại"));
    }

    private UserResponse mapToUserResponse(User user) {
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
