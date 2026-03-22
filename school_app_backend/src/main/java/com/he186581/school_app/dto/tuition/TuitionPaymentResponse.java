package com.he186581.school_app.dto.tuition;

import com.he186581.school_app.constant.PaymentMethod;
import com.he186581.school_app.constant.PaymentStatus;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TuitionPaymentResponse {

    private Long id;
    private Long studentId;
    private String studentName;
    private Long classId;
    private String className;
    private BigDecimal amount;
    private LocalDate dueDate;
    private LocalDate paidDate;
    private PaymentStatus status;
    private PaymentMethod paymentMethod;
    private String vnpTxnRef;
    private String orderInfo;
}
