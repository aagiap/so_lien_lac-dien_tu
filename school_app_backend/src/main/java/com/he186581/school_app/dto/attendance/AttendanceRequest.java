package com.he186581.school_app.dto.attendance;

import com.he186581.school_app.constant.AttendanceStatus;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import lombok.Data;

@Data
public class AttendanceRequest {

    @NotNull(message = "Student id không được để trống")
    private Long studentId;

    @NotNull(message = "Class id không được để trống")
    private Long classId;

    @NotNull(message = "Subject id không được để trống")
    private Long subjectId;

    private Long scheduleId;

    @NotNull(message = "Ngày điểm danh không được để trống")
    private LocalDate attendanceDate;

    @NotNull(message = "Trạng thái không được để trống")
    private AttendanceStatus status;

    private String note;
}
