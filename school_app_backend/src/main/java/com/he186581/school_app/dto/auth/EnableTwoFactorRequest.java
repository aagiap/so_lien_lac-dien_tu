package com.he186581.school_app.dto.auth;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class EnableTwoFactorRequest {

    @NotBlank(message = "OTP không được để trống")
    private String otp;
}
