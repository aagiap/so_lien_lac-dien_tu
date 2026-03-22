package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.schedule.ScheduleRequest;
import com.he186581.school_app.dto.schedule.ScheduleResponse;
import com.he186581.school_app.entity.Schedule;
import com.he186581.school_app.entity.SchoolClass;
import com.he186581.school_app.entity.Subject;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.ScheduleRepository;
import com.he186581.school_app.repository.SchoolClassRepository;
import com.he186581.school_app.service.ScheduleService;
import com.he186581.school_app.service.SubjectService;
import com.he186581.school_app.service.UserService;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class ScheduleServiceImpl implements ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final SubjectService subjectService;
    private final UserService userService;

    @Override
    public ScheduleResponse createSchedule(String teacherUsername, ScheduleRequest request) {
        SchoolClass schoolClass = schoolClassRepository.findById(request.getClassId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp"));
        Subject subject = subjectService.getEntityById(request.getSubjectId());
        User teacher = userService.getEntityByUsername(teacherUsername);

        Schedule schedule = new Schedule();
        schedule.setSchoolClass(schoolClass);
        schedule.setSubject(subject);
        schedule.setTeacher(teacher);
        schedule.setLessonDate(request.getLessonDate());
        schedule.setStartTime(request.getStartTime());
        schedule.setEndTime(request.getEndTime());
        schedule.setRoom(request.getRoom());
        schedule.setNote(request.getNote());

        return mapToResponse(scheduleRepository.save(schedule));
    }

    @Override
    public List<ScheduleResponse> getScheduleByWeek(Long classId, LocalDate weekStart) {
        LocalDate weekEnd = weekStart.plusDays(6);
        return scheduleRepository.findBySchoolClassIdAndLessonDateBetweenOrderByLessonDateAscStartTimeAsc(
                        classId, weekStart, weekEnd)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private ScheduleResponse mapToResponse(Schedule schedule) {
        return ScheduleResponse.builder()
                .id(schedule.getId())
                .classId(schedule.getSchoolClass().getId())
                .className(schedule.getSchoolClass().getName())
                .subjectId(schedule.getSubject().getId())
                .subjectName(schedule.getSubject().getName())
                .teacherId(schedule.getTeacher().getId())
                .teacherName(schedule.getTeacher().getFullName())
                .lessonDate(schedule.getLessonDate())
                .startTime(schedule.getStartTime())
                .endTime(schedule.getEndTime())
                .room(schedule.getRoom())
                .note(schedule.getNote())
                .build();
    }
}
