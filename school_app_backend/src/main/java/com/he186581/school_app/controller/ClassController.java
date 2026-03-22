package com.he186581.school_app.controller;

import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.dto.schoolclass.ClassMemberRequest;
import com.he186581.school_app.dto.schoolclass.ClassMemberResponse;
import com.he186581.school_app.dto.schoolclass.ClassRequest;
import com.he186581.school_app.dto.schoolclass.ClassResponse;
import com.he186581.school_app.service.ClassService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/classes")
@RequiredArgsConstructor
public class ClassController {

    private final ClassService classService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ClassResponse>>> getAllClasses() {
        return ResponseEntity.ok(ApiResponse.<List<ClassResponse>>builder()
                .success(true)
                .message("Lấy danh sách lớp thành công")
                .data(classService.getAllClasses())
                .build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ApiResponse<ClassResponse>> createClass(@Valid @RequestBody ClassRequest request) {
        return ResponseEntity.ok(ApiResponse.<ClassResponse>builder()
                .success(true)
                .message("Tạo lớp thành công")
                .data(classService.createClass(request))
                .build());
    }

    @GetMapping("/{classId}/members")
    public ResponseEntity<ApiResponse<List<ClassMemberResponse>>> getMembers(@PathVariable("classId") Long classId) {
        return ResponseEntity.ok(ApiResponse.<List<ClassMemberResponse>>builder()
                .success(true)
                .message("Lấy danh sách thành viên lớp thành công")
                .data(classService.getMembers(classId))
                .build());
    }

    @PostMapping("/{classId}/members")
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ApiResponse<ClassMemberResponse>> addMember(
            @PathVariable("classId") Long classId,
            @Valid @RequestBody ClassMemberRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<ClassMemberResponse>builder()
                .success(true)
                .message("Thêm thành viên vào lớp thành công")
                .data(classService.addMember(classId, request))
                .build());
    }
}
