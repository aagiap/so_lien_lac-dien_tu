package com.he186581.school_app.dto.schedule;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalTime;
import lombok.Data;

@Data
public class ScheduleRequest {

    @NotNull(message = "Class id không được để trống")
    private Long classId;

    @NotNull(message = "Subject id không được để trống")
    private Long subjectId;

    @NotNull(message = "Ngày học không được để trống")
    private LocalDate lessonDate;

    @NotNull(message = "Giờ bắt đầu không được để trống")
    private LocalTime startTime;

    @NotNull(message = "Giờ kết thúc không được để trống")
    private LocalTime endTime;

    private String room;

    private String note;
}
