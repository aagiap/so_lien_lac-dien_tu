package com.he186581.school_app.controller;

import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.dto.subject.SubjectRequest;
import com.he186581.school_app.dto.subject.SubjectResponse;
import com.he186581.school_app.service.SubjectService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/subjects")
@RequiredArgsConstructor
public class SubjectController {

    private final SubjectService subjectService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<SubjectResponse>>> getAllSubjects() {
        return ResponseEntity.ok(ApiResponse.<List<SubjectResponse>>builder()
                .success(true)
                .message("Lấy danh sách môn học thành công")
                .data(subjectService.getAllSubjects())
                .build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ApiResponse<SubjectResponse>> createSubject(@Valid @RequestBody SubjectRequest request) {
        return ResponseEntity.ok(ApiResponse.<SubjectResponse>builder()
                .success(true)
                .message("Tạo môn học thành công")
                .data(subjectService.createSubject(request))
                .build());
    }
}
