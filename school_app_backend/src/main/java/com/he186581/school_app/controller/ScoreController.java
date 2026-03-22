package com.he186581.school_app.controller;

import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.dto.score.ScoreRequest;
import com.he186581.school_app.dto.score.ScoreResponse;
import com.he186581.school_app.constant.Semester;
import com.he186581.school_app.service.ScoreService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/scores")
@RequiredArgsConstructor
public class ScoreController {

    private final ScoreService scoreService;

    @GetMapping("/student")
    public ResponseEntity<ApiResponse<List<ScoreResponse>>> getStudentScores(
            @RequestParam("studentId") Long studentId,
            @RequestParam("semester") Semester semester
    ) {
        return ResponseEntity.ok(ApiResponse.<List<ScoreResponse>>builder()
                .success(true)
                .message("Lấy bảng điểm thành công")
                .data(scoreService.getStudentScores(studentId, semester))
                .build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ApiResponse<ScoreResponse>> createScore(
            Authentication authentication,
            @Valid @RequestBody ScoreRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<ScoreResponse>builder()
                .success(true)
                .message("Nhập điểm thành công")
                .data(scoreService.createScore(authentication.getName(), request))
                .build());
    }
}
