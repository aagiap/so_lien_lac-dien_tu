package com.he186581.school_app.service;

import com.he186581.school_app.dto.schedule.ScheduleRequest;
import com.he186581.school_app.dto.schedule.ScheduleResponse;
import java.time.LocalDate;
import java.util.List;

public interface ScheduleService {

    ScheduleResponse createSchedule(String teacherUsername, ScheduleRequest request);

    List<ScheduleResponse> getScheduleByWeek(Long classId, LocalDate weekStart);
}
