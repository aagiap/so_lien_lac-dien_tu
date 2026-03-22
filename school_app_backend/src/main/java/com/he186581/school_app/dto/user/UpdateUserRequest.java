package com.he186581.school_app.dto.user;

import com.he186581.school_app.constant.Gender;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;
import lombok.Data;

@Data
public class UpdateUserRequest {

    @NotBlank(message = "Họ tên không được để trống")
    private String fullName;

    private String phone;

    private Gender gender;

    private LocalDate dateOfBirth;

    private String address;
}
