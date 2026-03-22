package com.he186581.school_app.service.impl;

import com.he186581.school_app.service.EmailService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

/**
 * Gửi email đơn giản bằng Gmail SMTP.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Override
    public void sendSimpleEmail(String to, String subject, String content) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject(subject);
            message.setText(content);
            mailSender.send(message);
        } catch (Exception ex) {
            log.error("Không thể gửi email tới {}: {}", to, ex.getMessage());
        }
    }

    @Override
    public void sendResetPasswordEmail(String to, String resetUrl) {
        String content = "Bạn vừa yêu cầu đặt lại mật khẩu.\n"
                + "Vui lòng truy cập link sau để đặt lại mật khẩu:\n"
                + resetUrl + "\n\n"
                + "Nếu không phải bạn, vui lòng bỏ qua email này.";
        sendSimpleEmail(to, "Đặt lại mật khẩu - School App", content);
    }

    @Override
    public void sendAnnouncementEmail(List<String> recipients, String title, String content) {
        if (recipients == null || recipients.isEmpty()) {
            return;
        }

        recipients.stream()
                .filter(email -> email != null && !email.isBlank())
                .distinct()
                .forEach(email -> sendSimpleEmail(
                        email,
                        "Thông báo mới: " + title,
                        content
                ));
    }
}
