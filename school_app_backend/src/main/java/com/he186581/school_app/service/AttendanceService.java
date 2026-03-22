package com.he186581.school_app.service;

import com.he186581.school_app.dto.attendance.AttendanceRequest;
import com.he186581.school_app.dto.attendance.AttendanceResponse;
import java.util.List;

public interface AttendanceService {

    AttendanceResponse createAttendance(String teacherUsername, AttendanceRequest request);

    List<AttendanceResponse> getStudentAttendance(Long studentId);
}
