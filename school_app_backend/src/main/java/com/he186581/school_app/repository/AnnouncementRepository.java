package com.he186581.school_app.repository;

import com.he186581.school_app.entity.Announcement;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {

    List<Announcement> findBySchoolClassIdOrderByCreatedAtDesc(Long classId);
}
