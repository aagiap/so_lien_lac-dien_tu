package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.subject.SubjectRequest;
import com.he186581.school_app.dto.subject.SubjectResponse;
import com.he186581.school_app.entity.Subject;
import com.he186581.school_app.exception.BadRequestException;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.SubjectRepository;
import com.he186581.school_app.service.SubjectService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class SubjectServiceImpl implements SubjectService {

    private final SubjectRepository subjectRepository;

    @Override
    public SubjectResponse createSubject(SubjectRequest request) {
        subjectRepository.findByCode(request.getCode()).ifPresent(subject -> {
            throw new BadRequestException("Mã môn học đã tồn tại");
        });

        Subject subject = new Subject();
        subject.setCode(request.getCode());
        subject.setName(request.getName());
        subject.setDescription(request.getDescription());

        return mapToResponse(subjectRepository.save(subject));
    }

    @Override
    public List<SubjectResponse> getAllSubjects() {
        return subjectRepository.findAll().stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public Subject getEntityById(Long id) {
        return subjectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy môn học với id = " + id));
    }

    private SubjectResponse mapToResponse(Subject subject) {
        return SubjectResponse.builder()
                .id(subject.getId())
                .code(subject.getCode())
                .name(subject.getName())
                .description(subject.getDescription())
                .build();
    }
}
