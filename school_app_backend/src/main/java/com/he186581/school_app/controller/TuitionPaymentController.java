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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/tuition-payments")
@RequiredArgsConstructor
public class TuitionPaymentController {

    private final TuitionPaymentService tuitionPaymentService;

    @Value("${app.server-ip}")
    private String serverIp;

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
        
        // Redirect to Frontend using centralized server IP
        String baseUrl = "http://" + serverIp + ":5173";
        String redirectUrl = baseUrl + "/#/payment-result?status=" + response.getStatus().name() + "&txnRef=" + response.getVnpTxnRef();
        
        return ResponseEntity.status(org.springframework.http.HttpStatus.FOUND)
                .location(java.net.URI.create(redirectUrl))
                .build();
    }
}

