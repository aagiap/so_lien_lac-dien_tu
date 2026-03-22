package com.he186581.school_app.service;

import com.he186581.school_app.dto.tuition.TuitionPaymentRequest;
import com.he186581.school_app.dto.tuition.TuitionPaymentResponse;
import com.he186581.school_app.dto.tuition.VnPayUrlResponse;
import java.util.List;
import java.util.Map;

public interface TuitionPaymentService {

    TuitionPaymentResponse createPayment(TuitionPaymentRequest request);

    List<TuitionPaymentResponse> getByStudent(Long studentId);

    List<TuitionPaymentResponse> getAllPayments();

    VnPayUrlResponse createVnPayUrl(Long paymentId, String clientIp);

    TuitionPaymentResponse handleVnPayReturn(Map<String, String> queryParams);
}
