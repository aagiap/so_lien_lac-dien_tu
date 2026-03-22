package com.he186581.school_app.service.impl;

import com.he186581.school_app.dto.tuition.TuitionPaymentRequest;
import com.he186581.school_app.dto.tuition.TuitionPaymentResponse;
import com.he186581.school_app.dto.tuition.VnPayUrlResponse;
import com.he186581.school_app.constant.PaymentMethod;
import com.he186581.school_app.constant.PaymentStatus;
import com.he186581.school_app.entity.SchoolClass;
import com.he186581.school_app.entity.TuitionPayment;
import com.he186581.school_app.entity.User;
import com.he186581.school_app.exception.BadRequestException;
import com.he186581.school_app.exception.ResourceNotFoundException;
import com.he186581.school_app.repository.SchoolClassRepository;
import com.he186581.school_app.repository.TuitionPaymentRepository;
import com.he186581.school_app.repository.UserRepository;
import com.he186581.school_app.service.TuitionPaymentService;
import com.he186581.school_app.util.VnPayUtil;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class TuitionPaymentServiceImpl implements TuitionPaymentService {

    private final TuitionPaymentRepository tuitionPaymentRepository;
    private final UserRepository userRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final VnPayUtil vnPayUtil;

    @Override
    public TuitionPaymentResponse createPayment(TuitionPaymentRequest request) {
        User student = userRepository.findById(request.getStudentId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy học sinh"));
        SchoolClass schoolClass = schoolClassRepository.findById(request.getClassId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy lớp"));

        TuitionPayment payment = new TuitionPayment();
        payment.setStudent(student);
        payment.setSchoolClass(schoolClass);
        payment.setAmount(request.getAmount());
        payment.setDueDate(request.getDueDate());
        payment.setPaymentMethod(request.getPaymentMethod());
        payment.setStatus(PaymentStatus.UNPAID);
        payment.setOrderInfo(request.getOrderInfo());

        return mapToResponse(tuitionPaymentRepository.save(payment));
    }

    @Override
    public List<TuitionPaymentResponse> getByStudent(Long studentId) {
        return tuitionPaymentRepository.findByStudentIdOrderByDueDateDesc(studentId)
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public List<TuitionPaymentResponse> getAllPayments() {
        return tuitionPaymentRepository.findAllByOrderByDueDateDesc()
                .stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Override
    public VnPayUrlResponse createVnPayUrl(Long paymentId, String clientIp) {
        TuitionPayment payment = tuitionPaymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy học phí"));

        if (payment.getVnpTxnRef() == null || payment.getVnpTxnRef().isBlank()) {
            payment.setVnpTxnRef(generateTxnRef());
        }
        payment.setPaymentMethod(PaymentMethod.VNPAY);
        payment.setStatus(PaymentStatus.PENDING);
        TuitionPayment saved = tuitionPaymentRepository.save(payment);

        return VnPayUrlResponse.builder()
                .txnRef(saved.getVnpTxnRef())
                .paymentUrl(vnPayUtil.createPaymentUrl(saved, clientIp))
                .build();
    }

    @Override
    public TuitionPaymentResponse handleVnPayReturn(Map<String, String> queryParams) {
        boolean valid = vnPayUtil.validateReturnData(queryParams);
        if (!valid) {
            throw new BadRequestException("Dữ liệu trả về từ VNPay không hợp lệ");
        }

        String txnRef = queryParams.get("vnp_TxnRef");
        String responseCode = queryParams.get("vnp_ResponseCode");

        TuitionPayment payment = tuitionPaymentRepository.findByVnpTxnRef(txnRef)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy giao dịch học phí"));

        if ("00".equals(responseCode)) {
            payment.setStatus(PaymentStatus.PAID);
            payment.setPaidDate(LocalDate.now());
        } else {
            payment.setStatus(PaymentStatus.UNPAID);
        }

        return mapToResponse(tuitionPaymentRepository.save(payment));
    }

    private String generateTxnRef() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase();
    }

    private TuitionPaymentResponse mapToResponse(TuitionPayment payment) {
        return TuitionPaymentResponse.builder()
                .id(payment.getId())
                .studentId(payment.getStudent().getId())
                .studentName(payment.getStudent().getFullName())
                .classId(payment.getSchoolClass().getId())
                .className(payment.getSchoolClass().getName())
                .amount(payment.getAmount())
                .dueDate(payment.getDueDate())
                .paidDate(payment.getPaidDate())
                .status(payment.getStatus())
                .paymentMethod(payment.getPaymentMethod())
                .vnpTxnRef(payment.getVnpTxnRef())
                .orderInfo(payment.getOrderInfo())
                .build();
    }
}
