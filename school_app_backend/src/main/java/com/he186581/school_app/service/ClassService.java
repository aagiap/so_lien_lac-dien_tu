package com.he186581.school_app.service;

import com.he186581.school_app.dto.schoolclass.ClassMemberRequest;
import com.he186581.school_app.dto.schoolclass.ClassMemberResponse;
import com.he186581.school_app.dto.schoolclass.ClassRequest;
import com.he186581.school_app.dto.schoolclass.ClassResponse;
import java.util.List;

public interface ClassService {

    ClassResponse createClass(ClassRequest request);

    List<ClassResponse> getAllClasses();

    ClassMemberResponse addMember(Long classId, ClassMemberRequest request);

    List<ClassMemberResponse> getMembers(Long classId);
}
