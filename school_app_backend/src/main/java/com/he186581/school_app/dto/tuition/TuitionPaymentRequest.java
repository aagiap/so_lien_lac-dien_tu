package com.he186581.school_app.dto.tuition;

import com.he186581.school_app.constant.PaymentMethod;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Data;

@Data
public class TuitionPaymentRequest {

    @NotNull(message = "Student id không được để trống")
    private Long studentId;

    @NotNull(message = "Class id không được để trống")
    private Long classId;

    @NotNull(message = "Số tiền không được để trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Số tiền phải > 0")
    private BigDecimal amount;

    @NotNull(message = "Hạn thanh toán không được để trống")
    private LocalDate dueDate;

    private PaymentMethod paymentMethod;

    private String orderInfo;
}
