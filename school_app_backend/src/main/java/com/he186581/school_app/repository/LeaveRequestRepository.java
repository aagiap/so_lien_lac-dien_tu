package com.he186581.school_app.repository;

import com.he186581.school_app.entity.LeaveRequest;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {

    List<LeaveRequest> findByStudentIdOrderByCreatedAtDesc(Long studentId);

    List<LeaveRequest> findBySchoolClassIdOrderByCreatedAtDesc(Long classId);

    List<LeaveRequest> findAllByOrderByCreatedAtDesc();
}
