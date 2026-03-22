package com.he186581.school_app.controller;

import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.dto.leave.LeaveRequestCreateRequest;
import com.he186581.school_app.dto.leave.LeaveRequestResponse;
import com.he186581.school_app.dto.leave.LeaveRequestReviewRequest;
import com.he186581.school_app.service.LeaveRequestService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/leave-requests")
@RequiredArgsConstructor
public class LeaveRequestController {

    private final LeaveRequestService leaveRequestService;

    @GetMapping("/my")
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<List<LeaveRequestResponse>>> getMyRequests(Authentication authentication) {
        return ResponseEntity.ok(ApiResponse.<List<LeaveRequestResponse>>builder()
                .success(true)
                .message("Lấy danh sách đơn nghỉ học thành công")
                .data(leaveRequestService.getMyRequests(authentication.getName()))
                .build());
    }

    @GetMapping("/all")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ApiResponse<List<LeaveRequestResponse>>> getAllRequests() {
        return ResponseEntity.ok(ApiResponse.<List<LeaveRequestResponse>>builder()
                .success(true)
                .message("Lấy tất cả đơn nghỉ học thành công")
                .data(leaveRequestService.getAllRequests())
                .build());
    }

    @PostMapping
    @PreAuthorize("hasRole('STUDENT')")
    public ResponseEntity<ApiResponse<LeaveRequestResponse>> createLeaveRequest(
            Authentication authentication,
            @Valid @RequestBody LeaveRequestCreateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<LeaveRequestResponse>builder()
                .success(true)
                .message("Gửi đơn nghỉ học thành công")
                .data(leaveRequestService.createLeaveRequest(authentication.getName(), request))
                .build());
    }

    @PutMapping("/{requestId}/review")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ApiResponse<LeaveRequestResponse>> reviewLeaveRequest(
            @PathVariable("requestId") Long requestId,
            Authentication authentication,
            @Valid @RequestBody LeaveRequestReviewRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<LeaveRequestResponse>builder()
                .success(true)
                .message("Xử lý đơn nghỉ học thành công")
                .data(leaveRequestService.reviewLeaveRequest(requestId, authentication.getName(), request))
                .build());
    }
}
