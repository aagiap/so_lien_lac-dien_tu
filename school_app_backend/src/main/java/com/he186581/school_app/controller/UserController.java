package com.he186581.school_app.controller;

import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.dto.user.ChangePasswordRequest;
import com.he186581.school_app.dto.user.UpdateUserRequest;
import com.he186581.school_app.dto.user.UserResponse;
import com.he186581.school_app.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getMe(Authentication authentication) {
        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
                .success(true)
                .message("Lấy thông tin cá nhân thành công")
                .data(userService.getCurrentUser(authentication.getName()))
                .build());
    }

    @GetMapping("/directory")
    public ResponseEntity<ApiResponse<java.util.List<UserResponse>>> getDirectory() {
        return ResponseEntity.ok(ApiResponse.<java.util.List<UserResponse>>builder()
                .success(true)
                .message("Lấy danh bạ người dùng thành công")
                .data(userService.getAllUsers())
                .build());
    }

    @PutMapping("/update")
    public ResponseEntity<ApiResponse<UserResponse>> update(
            Authentication authentication,
            @Valid @RequestBody UpdateUserRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<UserResponse>builder()
                .success(true)
                .message("Cập nhật thông tin thành công")
                .data(userService.updateCurrentUser(authentication.getName(), request))
                .build());
    }

    @PutMapping("/change-password")
    public ResponseEntity<ApiResponse<Object>> changePassword(
            Authentication authentication,
            @Valid @RequestBody ChangePasswordRequest request
    ) {
        userService.changePassword(authentication.getName(), request);
        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Đổi mật khẩu thành công")
                .data(null)
                .build());
    }
}
