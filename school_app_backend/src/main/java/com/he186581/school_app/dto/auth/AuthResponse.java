package com.he186581.school_app.dto.auth;

import com.he186581.school_app.dto.user.UserResponse;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Kết quả login / verify OTP / refresh.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

    private boolean requiresOtp;
    private String temporaryToken;
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private UserResponse user;
}
