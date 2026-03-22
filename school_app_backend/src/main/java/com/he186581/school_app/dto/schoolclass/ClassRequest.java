package com.he186581.school_app.dto.schoolclass;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ClassRequest {

    @NotBlank(message = "Tên lớp không được để trống")
    private String name;

    @NotNull(message = "Khối lớp không được để trống")
    private Integer gradeLevel;

    @NotBlank(message = "Niên khóa không được để trống")
    private String schoolYear;

    private Long homeroomTeacherId;
}
