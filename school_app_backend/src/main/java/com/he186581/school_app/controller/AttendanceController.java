package com.he186581.school_app.controller;

import com.he186581.school_app.dto.attendance.AttendanceRequest;
import com.he186581.school_app.dto.attendance.AttendanceResponse;
import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.service.AttendanceService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;

    @GetMapping("/student")
    public ResponseEntity<ApiResponse<List<AttendanceResponse>>> getStudentAttendance(@RequestParam("studentId") Long studentId) {
        return ResponseEntity.ok(ApiResponse.<List<AttendanceResponse>>builder()
                .success(true)
                .message("Lấy lịch sử điểm danh thành công")
                .data(attendanceService.getStudentAttendance(studentId))
                .build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ApiResponse<AttendanceResponse>> createAttendance(
            Authentication authentication,
            @Valid @RequestBody AttendanceRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<AttendanceResponse>builder()
                .success(true)
                .message("Điểm danh thành công")
                .data(attendanceService.createAttendance(authentication.getName(), request))
                .build());
    }
}
