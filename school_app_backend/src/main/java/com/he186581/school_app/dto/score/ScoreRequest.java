package com.he186581.school_app.dto.score;

import com.he186581.school_app.constant.ScoreType;
import com.he186581.school_app.constant.Semester;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.Data;

@Data
public class ScoreRequest {

    @NotNull(message = "Student id không được để trống")
    private Long studentId;

    @NotNull(message = "Class id không được để trống")
    private Long classId;

    @NotNull(message = "Subject id không được để trống")
    private Long subjectId;

    @NotNull(message = "Semester không được để trống")
    private Semester semester;

    @NotNull(message = "Loại điểm không được để trống")
    private ScoreType scoreType;

    @NotNull(message = "Điểm không được để trống")
    @DecimalMin(value = "0.0", inclusive = true, message = "Điểm phải >= 0")
    @DecimalMax(value = "10.0", inclusive = true, message = "Điểm phải <= 10")
    private BigDecimal scoreValue;

    private String comment;
}
