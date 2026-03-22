package com.he186581.school_app.service;

import com.he186581.school_app.dto.subject.SubjectRequest;
import com.he186581.school_app.dto.subject.SubjectResponse;
import com.he186581.school_app.entity.Subject;
import java.util.List;

public interface SubjectService {

    SubjectResponse createSubject(SubjectRequest request);

    List<SubjectResponse> getAllSubjects();

    Subject getEntityById(Long id);
}
