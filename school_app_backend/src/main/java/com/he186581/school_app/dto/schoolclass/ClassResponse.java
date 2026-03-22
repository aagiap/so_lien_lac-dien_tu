package com.he186581.school_app.dto.schoolclass;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClassResponse {

    private Long id;
    private String name;
    private Integer gradeLevel;
    private String schoolYear;
    private Long homeroomTeacherId;
    private String homeroomTeacherName;
}
