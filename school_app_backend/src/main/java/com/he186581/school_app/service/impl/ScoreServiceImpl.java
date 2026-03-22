package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.score.ScoreRequest;
import com.he186581.school_app.dto.score.ScoreResponse;
import com.he186581.school_app.entity.Score;
import com.he186581.school_app.entity.SchoolClass;
import com.he186581.school_app.entity.Subject;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.constant.Semester;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.ScoreRepository;
import com.he186581.school_app.repository.SchoolClassRepository;
import com.he186581.school_app.repository.UserRepository;
import com.he186581.school_app.service.ScoreService;
import com.he186581.school_app.service.SubjectService;
import com.he186581.school_app.service.UserService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class ScoreServiceImpl implements ScoreService {

    private final ScoreRepository scoreRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final UserRepository userRepository;
    private final SubjectService subjectService;
    private final UserService userService;

    @Override
    public ScoreResponse createScore(String teacherUsername, ScoreRequest request) {
        User teacher = userService.getEntityByUsername(teacherUsername);
        User student = userRepository.findById(request.getStudentId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy học sinh"));
        SchoolClass schoolClass = schoolClassRepository.findById(request.getClassId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp"));
        Subject subject = subjectService.getEntityById(request.getSubjectId());

        Score score = new Score();
        score.setTeacher(teacher);
        score.setStudent(student);
        score.setSchoolClass(schoolClass);
        score.setSubject(subject);
        score.setSemester(request.getSemester());
        score.setScoreType(request.getScoreType());
        score.setScoreValue(request.getScoreValue());
        score.setComment(request.getComment());

        return mapToResponse(scoreRepository.save(score));
    }

    @Override
    public List<ScoreResponse> getStudentScores(Long studentId, Semester semester) {
        return scoreRepository.findByStudentIdAndSemesterOrderByCreatedAtDesc(studentId, semester)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    private ScoreResponse mapToResponse(Score score) {
        return ScoreResponse.builder()
                .id(score.getId())
                .studentId(score.getStudent().getId())
                .studentName(score.getStudent().getFullName())
                .classId(score.getSchoolClass().getId())
                .className(score.getSchoolClass().getName())
                .subjectId(score.getSubject().getId())
                .subjectName(score.getSubject().getName())
                .teacherId(score.getTeacher().getId())
                .teacherName(score.getTeacher().getFullName())
                .semester(score.getSemester())
                .scoreType(score.getScoreType())
                .scoreValue(score.getScoreValue())
                .comment(score.getComment())
                .createdAt(score.getCreatedAt())
                .build();
    }
}
