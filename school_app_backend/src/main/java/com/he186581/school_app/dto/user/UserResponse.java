package com.he186581.school_app.dto.user;

import com.he186581.school_app.constant.Gender;
import java.time.LocalDate;
import java.util.Set;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO trả thông tin user.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {

    private Long id;
    private String username;
    private String fullName;
    private String email;
    private String phone;
    private Gender gender;
    private LocalDate dateOfBirth;
    private String address;
    private String studentCode;
    private String teacherCode;
    private String parentCode;
    private Boolean twoFactorEnabled;
    private Boolean active;
    private Set<String> roles;
}
