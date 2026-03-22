package com.he186581.school_app.service;

import com.he186581.school_app.dto.score.ScoreRequest;
import com.he186581.school_app.dto.score.ScoreResponse;
import com.he186581.school_app.constant.Semester;
import java.util.List;

public interface ScoreService {

    ScoreResponse createScore(String teacherUsername, ScoreRequest request);

    List<ScoreResponse> getStudentScores(Long studentId, Semester semester);
}
