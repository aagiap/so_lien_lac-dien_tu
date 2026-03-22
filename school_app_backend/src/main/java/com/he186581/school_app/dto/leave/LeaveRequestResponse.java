package com.he186581.school_app.dto.leave;

import com.he186581.school_app.constant.LeaveRequestStatus;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaveRequestResponse {

    private Long id;
    private Long studentId;
    private String studentName;
    private Long classId;
    private String className;
    private LocalDate fromDate;
    private LocalDate toDate;
    private String reason;
    private LeaveRequestStatus status;
    private Long reviewedById;
    private String reviewedByName;
    private String responseNote;
    private LocalDateTime createdAt;
    private LocalDateTime reviewedAt;
}
