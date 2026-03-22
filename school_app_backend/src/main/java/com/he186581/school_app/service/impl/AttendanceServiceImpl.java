package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.attendance.AttendanceRequest;
import com.he186581.school_app.dto.attendance.AttendanceResponse;
import com.he186581.school_app.entity.Attendance;
import com.he186581.school_app.entity.Schedule;
import com.he186581.school_app.entity.SchoolClass;
import com.he186581.school_app.entity.Subject;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.AttendanceRepository;
import com.he186581.school_app.repository.ScheduleRepository;
import com.he186581.school_app.repository.SchoolClassRepository;
import com.he186581.school_app.repository.UserRepository;
import com.he186581.school_app.service.AttendanceService;
import com.he186581.school_app.service.SubjectService;
import com.he186581.school_app.service.UserService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AttendanceServiceImpl implements AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final ScheduleRepository scheduleRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final UserRepository userRepository;
    private final SubjectService subjectService;
    private final UserService userService;

    @Override
    public AttendanceResponse createAttendance(String teacherUsername, AttendanceRequest request) {
        User teacher = userService.getEntityByUsername(teacherUsername);
        User student = userRepository.findById(request.getStudentId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy học sinh"));
        SchoolClass schoolClass = schoolClassRepository.findById(request.getClassId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp"));
        Subject subject = subjectService.getEntityById(request.getSubjectId());

        Attendance attendance = new Attendance();
        attendance.setTeacher(teacher);
        attendance.setStudent(student);
        attendance.setSchoolClass(schoolClass);
        attendance.setSubject(subject);
        attendance.setAttendanceDate(request.getAttendanceDate());
        attendance.setStatus(request.getStatus());
        attendance.setNote(request.getNote());

        if (request.getScheduleId() != null) {
            Schedule schedule = scheduleRepository.findById(request.getScheduleId())
                    .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy buổi học"));
            attendance.setSchedule(schedule);
        }

        return mapToResponse(attendanceRepository.save(attendance));
    }

    @Override
    public List<AttendanceResponse> getStudentAttendance(Long studentId) {
        return attendanceRepository.findByStudentIdOrderByAttendanceDateDesc(studentId)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private AttendanceResponse mapToResponse(Attendance attendance) {
        return AttendanceResponse.builder()
                .id(attendance.getId())
                .studentId(attendance.getStudent().getId())
                .studentName(attendance.getStudent().getFullName())
                .classId(attendance.getSchoolClass().getId())
                .className(attendance.getSchoolClass().getName())
                .subjectId(attendance.getSubject().getId())
                .subjectName(attendance.getSubject().getName())
                .teacherId(attendance.getTeacher().getId())
                .teacherName(attendance.getTeacher().getFullName())
                .scheduleId(attendance.getSchedule() != null ? attendance.getSchedule().getId() : null)
                .attendanceDate(attendance.getAttendanceDate())
                .status(attendance.getStatus())
                .note(attendance.getNote())
                .build();
    }
}
