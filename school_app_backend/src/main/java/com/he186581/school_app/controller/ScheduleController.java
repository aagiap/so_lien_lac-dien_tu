package com.he186581.school_app.controller;

import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.dto.schedule.ScheduleRequest;
import com.he186581.school_app.dto.schedule.ScheduleResponse;
import com.he186581.school_app.service.ScheduleService;
import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/schedule")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    @GetMapping("/week")
    public ResponseEntity<ApiResponse<List<ScheduleResponse>>> getByWeek(
            @RequestParam("classId") Long classId,
            @RequestParam("weekStart") LocalDate weekStart
    ) {
        return ResponseEntity.ok(ApiResponse.<List<ScheduleResponse>>builder()
                .success(true)
                .message("Lấy thời khóa biểu theo tuần thành công")
                .data(scheduleService.getScheduleByWeek(classId, weekStart))
                .build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ApiResponse<ScheduleResponse>> createSchedule(
            Authentication authentication,
            @Valid @RequestBody ScheduleRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<ScheduleResponse>builder()
                .success(true)
                .message("Tạo buổi học thành công")
                .data(scheduleService.createSchedule(authentication.getName(), request))
                .build());
    }
}
