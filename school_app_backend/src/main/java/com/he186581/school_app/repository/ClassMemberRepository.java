package com.he186581.school_app.repository;

import com.he186581.school_app.entity.ClassMember;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClassMemberRepository extends JpaRepository<ClassMember, Long> {

    List<ClassMember> findBySchoolClassId(Long classId);

    List<ClassMember> findByUserId(Long userId);

    Optional<ClassMember> findBySchoolClassIdAndUserId(Long classId, Long userId);
}
