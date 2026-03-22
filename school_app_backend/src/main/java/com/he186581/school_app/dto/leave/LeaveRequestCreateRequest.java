package com.he186581.school_app.dto.leave;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import lombok.Data;

@Data
public class LeaveRequestCreateRequest {

    @NotNull(message = "Class id không được để trống")
    private Long classId;

    @NotNull(message = "Ngày bắt đầu không được để trống")
    private LocalDate fromDate;

    @NotNull(message = "Ngày kết thúc không được để trống")
    private LocalDate toDate;

    @NotBlank(message = "Lý do không được để trống")
    private String reason;
}
