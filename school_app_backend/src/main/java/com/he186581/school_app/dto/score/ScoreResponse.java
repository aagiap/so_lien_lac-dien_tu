package com.he186581.school_app.dto.score;

import com.he186581.school_app.constant.ScoreType;
import com.he186581.school_app.constant.Semester;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScoreResponse {

    private Long id;
    private Long studentId;
    private String studentName;
    private Long classId;
    private String className;
    private Long subjectId;
    private String subjectName;
    private Long teacherId;
    private String teacherName;
    private Semester semester;
    private ScoreType scoreType;
    private BigDecimal scoreValue;
    private String comment;
    private LocalDateTime createdAt;
}
