package com.he186581.school_app.dto.leave;

import com.he186581.school_app.constant.LeaveRequestStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class LeaveRequestReviewRequest {

    @NotNull(message = "Trạng thái không được để trống")
    private LeaveRequestStatus status;

    private String responseNote;
}
