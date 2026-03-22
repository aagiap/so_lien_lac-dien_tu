package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.schoolclass.ClassMemberRequest;
import com.he186581.school_app.dto.schoolclass.ClassMemberResponse;
import com.he186581.school_app.dto.schoolclass.ClassRequest;
import com.he186581.school_app.dto.schoolclass.ClassResponse;
import com.he186581.school_app.entity.ClassMember;
import com.he186581.school_app.entity.SchoolClass;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.exception.BadRequestException;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.ClassMemberRepository;
import com.he186581.school_app.repository.SchoolClassRepository;
import com.he186581.school_app.repository.UserRepository;
import com.he186581.school_app.service.ClassService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class ClassServiceImpl implements ClassService {

    private final SchoolClassRepository schoolClassRepository;
    private final ClassMemberRepository classMemberRepository;
    private final UserRepository userRepository;

    @Override
    public ClassResponse createClass(ClassRequest request) {
        SchoolClass schoolClass = new SchoolClass();
        schoolClass.setName(request.getName());
        schoolClass.setGradeLevel(request.getGradeLevel());
        schoolClass.setSchoolYear(request.getSchoolYear());

        if (request.getHomeroomTeacherId() != null) {
            User teacher = getUserById(request.getHomeroomTeacherId());
            schoolClass.setHomeroomTeacher(teacher);
        }

        return mapToResponse(schoolClassRepository.save(schoolClass));
    }

    @Override
    public List<ClassResponse> getAllClasses() {
        return schoolClassRepository.findAll().stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public ClassMemberResponse addMember(Long classId, ClassMemberRequest request) {
        SchoolClass schoolClass = getClassById(classId);
        User user = getUserById(request.getUserId());

        classMemberRepository.findBySchoolClassIdAndUserId(classId, request.getUserId())
                .ifPresent(existing -> {
                    throw new BadRequestException("User đã tồn tại trong lớp");
                });

        ClassMember member = new ClassMember();
        member.setSchoolClass(schoolClass);
        member.setUser(user);
        member.setMemberRole(request.getMemberRole());

        if (request.getLinkedStudentId() != null) {
            member.setLinkedStudent(getUserById(request.getLinkedStudentId()));
        }

        return mapToMemberResponse(classMemberRepository.save(member));
    }

    @Override
    public List<ClassMemberResponse> getMembers(Long classId) {
        return classMemberRepository.findBySchoolClassId(classId).stream()
                .map(this::mapToMemberResponse)
                .toList();
    }

    private SchoolClass getClassById(Long classId) {
        return schoolClassRepository.findById(classId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp với id = " + classId));
    }

    private User getUserById(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy user với id = " + userId));
    }

    private ClassResponse mapToResponse(SchoolClass schoolClass) {
        return ClassResponse.builder()
                .id(schoolClass.getId())
                .name(schoolClass.getName())
                .gradeLevel(schoolClass.getGradeLevel())
                .schoolYear(schoolClass.getSchoolYear())
                .homeroomTeacherId(schoolClass.getHomeroomTeacher() != null ? schoolClass.getHomeroomTeacher().getId() : null)
                .homeroomTeacherName(schoolClass.getHomeroomTeacher() != null ? schoolClass.getHomeroomTeacher().getFullName() : null)
                .build();
    }

    private ClassMemberResponse mapToMemberResponse(ClassMember member) {
        return ClassMemberResponse.builder()
                .id(member.getId())
                .classId(member.getSchoolClass().getId())
                .userId(member.getUser().getId())
                .fullName(member.getUser().getFullName())
                .username(member.getUser().getUsername())
                .memberRole(member.getMemberRole())
                .linkedStudentId(member.getLinkedStudent() != null ? member.getLinkedStudent().getId() : null)
                .linkedStudentName(member.getLinkedStudent() != null ? member.getLinkedStudent().getFullName() : null)
                .build();
    }
}
