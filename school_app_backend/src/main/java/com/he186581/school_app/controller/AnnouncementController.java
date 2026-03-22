package com.he186581.school_app.controller;

import com.he186581.school_app.dto.announcement.AnnouncementRequest;
import com.he186581.school_app.dto.announcement.AnnouncementResponse;
import com.he186581.school_app.dto.common.ApiResponse;
import com.he186581.school_app.service.AnnouncementService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementService announcementService;

    @GetMapping("/class/{classId}")
    public ResponseEntity<ApiResponse<List<AnnouncementResponse>>> getByClass(@PathVariable("classId") Long classId) {
        return ResponseEntity.ok(ApiResponse.<List<AnnouncementResponse>>builder()
                .success(true)
                .message("Lấy danh sách thông báo thành công")
                .data(announcementService.getByClass(classId))
                .build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('TEACHER','ADMIN')")
    public ResponseEntity<ApiResponse<AnnouncementResponse>> createAnnouncement(
            Authentication authentication,
            @Valid @RequestBody AnnouncementRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.<AnnouncementResponse>builder()
                .success(true)
                .message("Tạo thông báo thành công")
                .data(announcementService.createAnnouncement(authentication.getName(), request))
                .build());
    }
}
