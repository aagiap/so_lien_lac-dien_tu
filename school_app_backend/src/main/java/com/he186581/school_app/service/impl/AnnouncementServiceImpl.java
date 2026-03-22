package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.announcement.AnnouncementRequest;
import com.he186581.school_app.dto.announcement.AnnouncementResponse;
import com.he186581.school_app.entity.Announcement;
import com.he186581.school_app.entity.SchoolClass;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.AnnouncementRepository;
import com.he186581.school_app.repository.ClassMemberRepository;
import com.he186581.school_app.repository.SchoolClassRepository;
import com.he186581.school_app.service.AnnouncementService;
import com.he186581.school_app.service.EmailService;
import com.he186581.school_app.service.UserService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AnnouncementServiceImpl implements AnnouncementService {

    private final AnnouncementRepository announcementRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final ClassMemberRepository classMemberRepository;
    private final UserService userService;
    private final EmailService emailService;
    private final org.springframework.messaging.simp.SimpMessagingTemplate messagingTemplate;

    @Override
    public AnnouncementResponse createAnnouncement(String teacherUsername, AnnouncementRequest request) {
        User teacher = userService.getEntityByUsername(teacherUsername);
        SchoolClass schoolClass = schoolClassRepository.findById(request.getClassId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp"));

        Announcement announcement = new Announcement();
        announcement.setSchoolClass(schoolClass);
        announcement.setTeacher(teacher);
        announcement.setTitle(request.getTitle());
        announcement.setContent(request.getContent());

        Announcement saved = announcementRepository.save(announcement);

        List<String> emails = classMemberRepository.findBySchoolClassId(request.getClassId()).stream()
                .map(member -> member.getUser().getEmail())
                .filter(email -> email != null && !email.isBlank())
                .toList();

        emailService.sendAnnouncementEmail(emails, saved.getTitle(), saved.getContent());

        AnnouncementResponse response = mapToResponse(saved);
        
        // Broadcast thông báo qua STOMP cho tất cả client đang theo dõi lớp này
        messagingTemplate.convertAndSend("/topic/announcements/" + request.getClassId(), response);

        return response;
    }

    @Override
    public List<AnnouncementResponse> getByClass(Long classId) {
        return announcementRepository.findBySchoolClassIdOrderByCreatedAtDesc(classId)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private AnnouncementResponse mapToResponse(Announcement announcement) {
        return AnnouncementResponse.builder()
                .id(announcement.getId())
                .classId(announcement.getSchoolClass().getId())
                .className(announcement.getSchoolClass().getName())
                .teacherId(announcement.getTeacher().getId())
                .teacherName(announcement.getTeacher().getFullName())
                .title(announcement.getTitle())
                .content(announcement.getContent())
                .createdAt(announcement.getCreatedAt())
                .build();
    }
}
