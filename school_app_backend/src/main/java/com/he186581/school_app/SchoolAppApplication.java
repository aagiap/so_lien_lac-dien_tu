package com.he186581.school_app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class SchoolAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(SchoolAppApplication.class, args);
    }
}
