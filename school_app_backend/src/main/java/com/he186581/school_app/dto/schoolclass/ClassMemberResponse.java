package com.he186581.school_app.dto.schoolclass;

import com.he186581.school_app.constant.MemberRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClassMemberResponse {

    private Long id;
    private Long classId;
    private Long userId;
    private String fullName;
    private String username;
    private MemberRole memberRole;
    private Long linkedStudentId;
    private String linkedStudentName;
}
