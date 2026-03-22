package com.he186581.school_app.dto.attendance;

import com.he186581.school_app.constant.AttendanceStatus;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AttendanceResponse {

    private Long id;
    private Long studentId;
    private String studentName;
    private Long classId;
    private String className;
    private Long subjectId;
    private String subjectName;
    private Long teacherId;
    private String teacherName;
    private Long scheduleId;
    private LocalDate attendanceDate;
    private AttendanceStatus status;
    private String note;
}
