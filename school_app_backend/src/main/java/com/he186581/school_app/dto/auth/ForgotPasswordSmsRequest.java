package com.he186581.school_app.dto.auth;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ForgotPasswordSmsRequest {

    @NotBlank(message = "Số điện thoại không được để trống")
    private String phone;
}
