package com.he186581.school_app.repository;

import com.he186581.school_app.entity.Attendance;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

    List<Attendance> findByStudentIdOrderByAttendanceDateDesc(Long studentId);

    List<Attendance> findByScheduleIdOrderByStudentIdAsc(Long scheduleId);
}
