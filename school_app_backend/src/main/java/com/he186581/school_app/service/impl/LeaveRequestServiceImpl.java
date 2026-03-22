package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.leave.LeaveRequestCreateRequest;
import com.he186581.school_app.dto.leave.LeaveRequestResponse;
import com.he186581.school_app.dto.leave.LeaveRequestReviewRequest;
import com.he186581.school_app.entity.LeaveRequest;
import com.he186581.school_app.constant.LeaveRequestStatus;
import com.he186581.school_app.entity.SchoolClass;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.exception.BadRequestException;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.LeaveRequestRepository;
import com.he186581.school_app.repository.SchoolClassRepository;
import com.he186581.school_app.service.LeaveRequestService;
import com.he186581.school_app.service.UserService;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class LeaveRequestServiceImpl implements LeaveRequestService {

    private final LeaveRequestRepository leaveRequestRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final UserService userService;

    @Override
    public LeaveRequestResponse createLeaveRequest(String studentUsername, LeaveRequestCreateRequest request) {
        if (request.getFromDate().isAfter(request.getToDate())) {
            throw new BadRequestException("Ngày bắt đầu không được sau ngày kết thúc");
        }

        User student = userService.getEntityByUsername(studentUsername);
        SchoolClass schoolClass = schoolClassRepository.findById(request.getClassId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp"));

        LeaveRequest leaveRequest = new LeaveRequest();
        leaveRequest.setStudent(student);
        leaveRequest.setSchoolClass(schoolClass);
        leaveRequest.setFromDate(request.getFromDate());
        leaveRequest.setToDate(request.getToDate());
        leaveRequest.setReason(request.getReason());
        leaveRequest.setStatus(LeaveRequestStatus.PENDING);

        return mapToResponse(leaveRequestRepository.save(leaveRequest));
    }

    @Override
    public LeaveRequestResponse reviewLeaveRequest(Long requestId, String teacherUsername, LeaveRequestReviewRequest request) {
        LeaveRequest leaveRequest = leaveRequestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn nghỉ học"));

        User teacher = userService.getEntityByUsername(teacherUsername);

        if (request.getStatus() == LeaveRequestStatus.PENDING) {
            throw new BadRequestException("Không thể review về trạng thái PENDING");
        }

        leaveRequest.setStatus(request.getStatus());
        leaveRequest.setReviewedBy(teacher);
        leaveRequest.setResponseNote(request.getResponseNote());
        leaveRequest.setReviewedAt(LocalDateTime.now());

        return mapToResponse(leaveRequestRepository.save(leaveRequest));
    }

    @Override
    public List<LeaveRequestResponse> getMyRequests(String studentUsername) {
        User student = userService.getEntityByUsername(studentUsername);
        return leaveRequestRepository.findByStudentIdOrderByCreatedAtDesc(student.getId())
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public List<LeaveRequestResponse> getAllRequests() {
        return leaveRequestRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private LeaveRequestResponse mapToResponse(LeaveRequest leaveRequest) {
        return LeaveRequestResponse.builder()
                .id(leaveRequest.getId())
                .studentId(leaveRequest.getStudent().getId())
                .studentName(leaveRequest.getStudent().getFullName())
                .classId(leaveRequest.getSchoolClass().getId())
                .className(leaveRequest.getSchoolClass().getName())
                .fromDate(leaveRequest.getFromDate())
                .toDate(leaveRequest.getToDate())
                .reason(leaveRequest.getReason())
                .status(leaveRequest.getStatus())
                .reviewedById(leaveRequest.getReviewedBy() != null ? leaveRequest.getReviewedBy().getId() : null)
                .reviewedByName(leaveRequest.getReviewedBy() != null ? leaveRequest.getReviewedBy().getFullName() : null)
                .responseNote(leaveRequest.getResponseNote())
                .createdAt(leaveRequest.getCreatedAt())
                .reviewedAt(leaveRequest.getReviewedAt())
                .build();
    }
}
