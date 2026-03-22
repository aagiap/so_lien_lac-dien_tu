package com.he186581.school_app.config;

import com.he186581.school_app.entity.Role;
import com.he186581.school_app.constant.RoleName;
import com.he186581.school_app.repository.RoleRepository;
import java.util.Arrays;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

/**
 * Tạo sẵn 4 role cơ bản khi project khởi động.
 */
@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final RoleRepository roleRepository;

    @Override
    public void run(String... args) {
        Arrays.stream(RoleName.values()).forEach(roleName -> {
            roleRepository.findByName(roleName)
                    .orElseGet(() -> roleRepository.save(Role.of(roleName)));
        });
    }
}
