# School App Backend - Spring Boot

Backend Web Service cho hệ thống Sổ liên lạc điện tử.

## Công nghệ
- Java 17
- Spring Boot
- Spring Security
- JWT
- JPA / Hibernate
- MySQL
- WebSocket (STOMP + SockJS)
- Gmail SMTP
- TOTP 2FA
- VNPay sandbox

## Cấu trúc package
`com.he186581.school_app`

- config
- security
- controller
- service
- service.impl
- repository
- entity
- dto
- util
- websocket
- exception

## Ghi chú
- Database chỉ dùng đúng 13 bảng theo yêu cầu.
- Refresh token và reset password dùng JWT, không tạo thêm bảng.
- 2FA dùng TOTP, hỗ trợ Google Authenticator / Microsoft Authenticator.
- Chat realtime dùng cả REST và WebSocket.
- VNPay mới ở mức skeleton dễ hiểu cho đồ án sinh viên, đủ để mở rộng tiếp.

## Chạy project
1. Tạo database `school_app` trong MySQL hoặc để app tự tạo.
2. Cập nhật `application.properties`.
3. Chạy:
   ```bash
   mvn spring-boot:run
   ```

## Tài khoản/roles
`DataSeeder` sẽ tạo sẵn các role:
- STUDENT
- TEACHER
- PARENT
- ADMIN
