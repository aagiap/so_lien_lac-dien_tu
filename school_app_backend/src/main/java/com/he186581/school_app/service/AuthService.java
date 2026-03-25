package com.he186581.school_app.service;

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

import java.util.Map;

public interface AuthService {

    AuthResponse login(LoginRequest request);

    AuthResponse verifyOtp(VerifyOtpRequest request);

    AuthResponse refreshToken(RefreshTokenRequest request);

    void forgotPassword(ForgotPasswordRequest request);

    void resetPassword(ResetPasswordRequest request);

    Map<String, String> forgotPasswordSms(ForgotPasswordSmsRequest request);

    void resetPasswordSms(ResetPasswordSmsRequest request);

    TwoFactorSetupResponse setup2fa(String username);

    void enable2fa(String username, EnableTwoFactorRequest request);

    void disable2fa(String username);

    void logout();
}
