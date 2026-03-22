package com.he186581.school_app.dto.auth;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class VerifyOtpRequest {

    @NotBlank(message = "Temporary token không được để trống")
    private String temporaryToken;

    @NotBlank(message = "OTP không được để trống")
    private String otp;
}
