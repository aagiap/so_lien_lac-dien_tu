package com.he186581.school_app.repository;

import com.he186581.school_app.entity.TuitionPayment;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TuitionPaymentRepository extends JpaRepository<TuitionPayment, Long> {

    List<TuitionPayment> findByStudentIdOrderByDueDateDesc(Long studentId);

    List<TuitionPayment> findAllByOrderByDueDateDesc();

    Optional<TuitionPayment> findByVnpTxnRef(String vnpTxnRef);
}
