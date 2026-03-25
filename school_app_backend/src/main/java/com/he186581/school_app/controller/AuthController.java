package com.he186581.school_app.controller;

import com.he186581.school_app.dto.auth.AuthResponse;
import com.he186581.school_app.dto.auth.EnableTwoFactorRequest;
import com.he186581.school_app.dto.auth.ForgotPasswordRequest;
import com.he186581.school_app.dto.auth.ForgotPasswordSmsRequest;
import com.he186581.school_app.dto.auth.LoginRequest;
import com.he186581.school_app.dto.auth.RefreshTokenRequest;
import com.he186581.school_app.dto.auth.ResetPasswordRequest;
import com.he186581.school_app.dto.auth.ResetPasswordSmsRequest;
import com.he186581.school_app.dto.auth.TwoFactorSetupResponse;
import com.he186581.school_app.dto.auth.VerifyOtpRequest;
import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.service.AuthService;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * API Authentication.
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(ApiResponse.<AuthResponse>builder()
                .success(true)
                .message("Đăng nhập thành công")
                .data(authService.login(request))
                .build());
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyOtp(@Valid @RequestBody VerifyOtpRequest request) {
        return ResponseEntity.ok(ApiResponse.<AuthResponse>builder()
                .success(true)
                .message("Xác thực OTP thành công")
                .data(authService.verifyOtp(request))
                .build());
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(ApiResponse.<AuthResponse>builder()
                .success(true)
                .message("Refresh token thành công")
                .data(authService.refreshToken(request))
                .build());
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Object>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.forgotPassword(request);
        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Nếu email tồn tại trong hệ thống, link reset password đã được gửi")
                .data(null)
                .build());
    }

    @PostMapping("/forgot-password-sms")
    public ResponseEntity<ApiResponse<Map<String, String>>> forgotPasswordSms(@Valid @RequestBody ForgotPasswordSmsRequest request) {
        Map<String, String> result = authService.forgotPasswordSms(request);
        return ResponseEntity.ok(ApiResponse.<Map<String, String>>builder()
                .success(true)
                .message("Mã OTP đã được gửi")
                .data(result)
                .build());
    }

    @PostMapping("/reset-password-sms")
    public ResponseEntity<ApiResponse<Object>> resetPasswordSms(@Valid @RequestBody ResetPasswordSmsRequest request) {
        authService.resetPasswordSms(request);
        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Đặt lại mật khẩu thành công")
                .data(null)
                .build());
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Object>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Đặt lại mật khẩu thành công")
                .data(null)
                .build());
    }

    @PostMapping("/setup-2fa")
    public ResponseEntity<ApiResponse<TwoFactorSetupResponse>> setup2fa(Authentication authentication) {
        return ResponseEntity.ok(ApiResponse.<TwoFactorSetupResponse>builder()
                .success(true)
                .message("Lấy secret 2FA thành công")
                .data(authService.setup2fa(authentication.getName()))
                .build());
    }

    @PostMapping("/enable-2fa")
    public ResponseEntity<ApiResponse<Object>> enable2fa(
            Authentication authentication,
            @Valid @RequestBody EnableTwoFactorRequest request
    ) {
        authService.enable2fa(authentication.getName(), request);
        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Bật 2FA thành công")
                .data(null)
                .build());
    }

    @PostMapping("/disable-2fa")
    public ResponseEntity<ApiResponse<Object>> disable2fa(Authentication authentication) {
        authService.disable2fa(authentication.getName());
        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Tắt 2FA thành công")
                .data(null)
                .build());
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Object>> logout() {
        authService.logout();
        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Logout thành công. Client hãy xoá access token và refresh token")
                .data(null)
                .build());
    }
}
