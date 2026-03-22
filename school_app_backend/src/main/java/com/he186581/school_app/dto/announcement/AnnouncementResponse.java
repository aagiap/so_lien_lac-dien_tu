package com.he186581.school_app.dto.announcement;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AnnouncementResponse {

    private Long id;
    private Long classId;
    private String className;
    private Long teacherId;
    private String teacherName;
    private String title;
    private String content;
    private LocalDateTime createdAt;
}
