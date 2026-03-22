package com.he186581.school_app.service;

import java.util.List;

public interface EmailService {

    void sendSimpleEmail(String to, String subject, String content);

    void sendResetPasswordEmail(String to, String resetUrl);

    void sendAnnouncementEmail(List<String> recipients, String title, String content);
}
