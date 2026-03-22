package com.he186581.school_app.repository;

import com.he186581.school_app.entity.Schedule;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    List<Schedule> findBySchoolClassIdAndLessonDateBetweenOrderByLessonDateAscStartTimeAsc(
            Long classId, LocalDate fromDate, LocalDate toDate);
}
