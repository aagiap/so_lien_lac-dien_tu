package com.he186581.school_app.service;

import com.he186581.school_app.dto.announcement.AnnouncementRequest;
import com.he186581.school_app.dto.announcement.AnnouncementResponse;
import java.util.List;

public interface AnnouncementService {

    AnnouncementResponse createAnnouncement(String teacherUsername, AnnouncementRequest request);

    List<AnnouncementResponse> getByClass(Long classId);
}
