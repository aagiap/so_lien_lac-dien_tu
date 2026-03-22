package com.he186581.school_app.dto.schoolclass;

import com.he186581.school_app.constant.MemberRole;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ClassMemberRequest {

    @NotNull(message = "User id không được để trống")
    private Long userId;

    @NotNull(message = "Member role không được để trống")
    private MemberRole memberRole;

    private Long linkedStudentId;
}
