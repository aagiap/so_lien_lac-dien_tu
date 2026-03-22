package com.he186581.school_app.repository;

import com.he186581.school_app.entity.Role;
import com.he186581.school_app.constant.RoleName;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoleRepository extends JpaRepository<Role, Long> {

    Optional<Role> findByName(RoleName name);
}
