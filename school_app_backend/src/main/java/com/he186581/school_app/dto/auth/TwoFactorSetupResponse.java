package com.he186581.school_app.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Trả secret và otpauth URL để app mobile/web tạo QR.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TwoFactorSetupResponse {

    private String secret;
    private String otpAuthUrl;
}
