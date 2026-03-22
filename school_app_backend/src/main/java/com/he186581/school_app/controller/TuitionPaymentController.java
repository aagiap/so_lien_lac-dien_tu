package com.he186581.school_app.controller;

import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.dto.tuition.TuitionPaymentRequest;
import com.he186581.school_app.dto.tuition.TuitionPaymentResponse;
import com.he186581.school_app.dto.tuition.VnPayUrlResponse;
import com.he186581.school_app.service.TuitionPaymentService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/tuition-payments")
@RequiredArgsConstructor
public class TuitionPaymentController {

    private final TuitionPaymentService tuitionPaymentService;

    @GetMapping("/student")
    public ResponseEntity<ApiResponse<List<TuitionPaymentResponse>>> getByStudent(@RequestParam("studentId") Long studentId) {
        return ResponseEntity.ok(ApiResponse.<List<TuitionPaymentResponse>>builder()
                .success(true)
                .message("Lấy danh sách học phí thành công")
                .data(tuitionPaymentService.getByStudent(studentId))
                .build());
    }

    @GetMapping("/all")
    @PreAuthorize("hasAnyRole('ADMIN','TEACHER')")
    public ResponseEntity<ApiResponse<List<TuitionPaymentResponse>>> getAllPayments() {
        return ResponseEntity.ok(ApiResponse.<List<TuitionPaymentResponse>>builder()
                .success(true)
                .message("Lấy toàn bộ học phí thành công")
                .data(tuitionPaymentService.getAllPayments())
                .build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','TEACHER')")
    public ResponseEntity<ApiResponse<TuitionPaymentResponse>> createPayment(
            @Valid @RequestBody TuitionPaymentRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<TuitionPaymentResponse>builder()
                .success(true)
                .message("Tạo học phí thành công")
                .data(tuitionPaymentService.createPayment(request))
                .build());
    }

    @GetMapping("/{paymentId}/vnpay-url")
    public ResponseEntity<ApiResponse<VnPayUrlResponse>> createVnPayUrl(
            @PathVariable("paymentId") Long paymentId,
            HttpServletRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<VnPayUrlResponse>builder()
                .success(true)
                .message("Tạo URL VNPay thành công")
                .data(tuitionPaymentService.createVnPayUrl(paymentId, request.getRemoteAddr()))
                .build());
    }

    @GetMapping("/vnpay-return")
    public ResponseEntity<Void> handleVnPayReturn(
            @RequestParam Map<String, String> queryParams
    ) {
        TuitionPaymentResponse response = tuitionPaymentService.handleVnPayReturn(queryParams);
        
        // Redirect to Frontend
        // Assuming app.frontend-reset-url logic can be used or an explicit frontend URL
        // We will hardcode the redirect to the FE URL based on the return URL base
        String baseUrl = "http://192.168.0.103:5173"; // Or read from properties
        String redirectUrl = baseUrl + "/#/payment-result?status=" + response.getStatus().name() + "&txnRef=" + response.getVnpTxnRef();
        
        return ResponseEntity.status(org.springframework.http.HttpStatus.FOUND)
                .location(java.net.URI.create(redirectUrl))
                .build();
    }
}
