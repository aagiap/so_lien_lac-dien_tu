package com.he186581.school_app.repository;

import com.he186581.school_app.entity.Score;
import com.he186581.school_app.constant.Semester;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ScoreRepository extends JpaRepository<Score, Long> {

    List<Score> findByStudentIdAndSemesterOrderByCreatedAtDesc(Long studentId, Semester semester);
}
