-- =============================================================
--  SCHOOL APP – DEMO DATA SQL
--  Mô tả: 4 tài khoản (Admin, Teacher, Student, Parent)
--         Học sinh (Nguyễn Văn An) – Giáo viên (Trần Thị Bích) – Phụ huynh (Nguyễn Văn Bình) liên kết nhau.
--
--  Chạy trong MySQL sau khi backend đã tạo schema (ddl-auto=update).
--  Mật khẩu tất cả tài khoản: Password@123
--  (BCrypt hash của "Password@123")
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================
-- 1. ROLES
-- =============================================================
INSERT IGNORE INTO roles (id, name) VALUES
(1, 'ADMIN'),
(2, 'TEACHER'),
(3, 'STUDENT'),
(4, 'PARENT');

-- =============================================================
-- 2. USERS
--    password = BCrypt("Password@123")
-- =============================================================
INSERT IGNORE INTO users
  (id, username, password, full_name, email, phone, gender, date_of_birth, address,
   student_code, teacher_code, parent_code,
   two_factor_enabled, two_factor_secret, active,
   created_at, updated_at)
VALUES
-- Admin
(1,
 'admin',
 '$2a$12$IENB5iFVY.7e24t4JckVMuMYCgJqxRWNmD9s.LijZMomj4YVvWgTW',
 'Nguyễn Quản Trị',
 'admin@school.edu.vn',
 '0901000001',
 'MALE',
 '1980-05-15',
 '01 Trần Phú, Hà Nội',
 NULL, NULL, NULL,
 FALSE, NULL, TRUE,
 NOW(), NOW()),

-- Teacher: Trần Thị Bích
(2,
 'teacher_bich',
 '$2a$12$IENB5iFVY.7e24t4JckVMuMYCgJqxRWNmD9s.LijZMomj4YVvWgTW',
 'Trần Thị Bích',
 'bich.tran@school.edu.vn',
 '0901000002',
 'FEMALE',
 '1985-08-20',
 '12 Lê Lợi, Hà Nội',
 NULL, 'GV001', NULL,
 FALSE, NULL, TRUE,
 NOW(), NOW()),

-- Student: Nguyễn Văn An
(3,
 'student_an',
 '$2a$12$IENB5iFVY.7e24t4JckVMuMYCgJqxRWNmD9s.LijZMomj4YVvWgTW',
 'Nguyễn Văn An',
 'an.nguyen@school.edu.vn',
 '0901000003',
 'MALE',
 '2009-03-12',
 '55 Nguyễn Huệ, Hà Nội',
 'HS001', NULL, NULL,
 FALSE, NULL, TRUE,
 NOW(), NOW()),

-- Parent: Nguyễn Văn Bình (bố của học sinh An)
(4,
 'parent_binh',
 '$2a$12$IENB5iFVY.7e24t4JckVMuMYCgJqxRWNmD9s.LijZMomj4YVvWgTW',
 'Nguyễn Văn Bình',
 'binh.nguyen@parent.vn',
 '0901000004',
 'MALE',
 '1975-11-03',
 '55 Nguyễn Huệ, Hà Nội',
 NULL, NULL, 'PH001',
 FALSE, NULL, TRUE,
 NOW(), NOW());

-- =============================================================
-- 3. USER_ROLES
-- =============================================================
INSERT IGNORE INTO user_roles (user_id, role_id) VALUES
(1, 1), -- admin  → ADMIN
(2, 2), -- bich   → TEACHER
(3, 3), -- an     → STUDENT
(4, 4); -- binh   → PARENT

-- =============================================================
-- 4. SUBJECTS
-- =============================================================
INSERT IGNORE INTO subjects (id, code, name, description, created_at, updated_at) VALUES
(1,  'TOAN',    'Toán học',         'Đại số, giải tích, hình học',             NOW(), NOW()),
(2,  'VAN',     'Ngữ văn',          'Văn học Việt Nam và thế giới',            NOW(), NOW()),
(3,  'ANH',     'Tiếng Anh',        'Giao tiếp và ngữ pháp tiếng Anh',        NOW(), NOW()),
(4,  'LY',      'Vật lý',           'Cơ học, điện, quang học',                NOW(), NOW()),
(5,  'HOA',     'Hóa học',          'Hóa vô cơ và hữu cơ',                   NOW(), NOW()),
(6,  'SINH',    'Sinh học',         'Sinh học tế bào, di truyền học',         NOW(), NOW()),
(7,  'SU',      'Lịch sử',          'Lịch sử Việt Nam và thế giới',           NOW(), NOW()),
(8,  'DIA',     'Địa lý',           'Địa lý tự nhiên và kinh tế xã hội',     NOW(), NOW());

-- =============================================================
-- 5. CLASSES
--    Lớp 10A1 – GVCN: cô Trần Thị Bích
-- =============================================================
INSERT IGNORE INTO classes
  (id, class_name, grade_level, school_year, homeroom_teacher_id, created_at, updated_at)
VALUES
(1, '10A1', 10, '2025-2026', 2, NOW(), NOW());

-- =============================================================
-- 6. CLASS_MEMBERS
--    Teacher Bích là giáo viên lớp 10A1
--    Student An là học sinh lớp 10A1
--    Parent Bình là phụ huynh của học sinh An trong lớp 10A1
-- =============================================================
INSERT IGNORE INTO class_members
  (id, class_id, user_id, member_role, linked_student_id, created_at, updated_at)
VALUES
(1, 1, 2, 'TEACHER',  NULL, NOW(), NOW()),  -- Cô Bích – Giáo viên
(2, 1, 3, 'STUDENT',  NULL, NOW(), NOW()),  -- An – Học sinh
(3, 1, 4, 'PARENT',   3,    NOW(), NOW());  -- Bình – PH của An (linked_student_id = 3)

-- =============================================================
-- 7. SCHEDULE (Thời khóa biểu tuần hiện tại: 17-21/03/2026)
-- =============================================================
INSERT IGNORE INTO schedule
  (id, class_id, subject_id, teacher_id, lesson_date, start_time, end_time, room, note, created_at, updated_at)
VALUES
-- Thứ 2 (17/03)
(1,  1, 1, 2, '2026-03-17', '07:00:00', '08:30:00', 'P.201', NULL, NOW(), NOW()),  -- Toán
(2,  1, 2, 2, '2026-03-17', '09:00:00', '10:30:00', 'P.201', NULL, NOW(), NOW()),  -- Văn
-- Thứ 3 (18/03)
(3,  1, 3, 2, '2026-03-18', '07:00:00', '08:30:00', 'P.203', NULL, NOW(), NOW()),  -- Anh
(4,  1, 4, 2, '2026-03-18', '09:00:00', '10:30:00', 'P.207', 'Thực hành', NOW(), NOW()),  -- Lý
-- Thứ 4 (19/03)
(5,  1, 5, 2, '2026-03-19', '07:00:00', '08:30:00', 'PTN',   'Thí nghiệm hóa', NOW(), NOW()),  -- Hóa
(6,  1, 1, 2, '2026-03-19', '09:00:00', '10:30:00', 'P.201', NULL, NOW(), NOW()),  -- Toán
-- Thứ 5 (20/03)
(7,  1, 6, 2, '2026-03-20', '07:00:00', '08:30:00', 'P.205', NULL, NOW(), NOW()),  -- Sinh
(8,  1, 7, 2, '2026-03-20', '09:00:00', '10:30:00', 'P.202', NULL, NOW(), NOW()),  -- Sử
-- Thứ 6 (21/03)
(9,  1, 8, 2, '2026-03-21', '07:00:00', '08:30:00', 'P.204', NULL, NOW(), NOW()),  -- Địa
(10, 1, 2, 2, '2026-03-21', '09:00:00', '10:30:00', 'P.201', NULL, NOW(), NOW());  -- Văn

-- =============================================================
-- 8. SCORES – HỌC SINH AN (id=3), LỚP 10A1 (id=1), GV Bích (id=2)
-- =============================================================
-- === HỌC KỲ 1 ===
-- Toán
INSERT IGNORE INTO scores (id, student_id, subject_id, teacher_id, class_id, semester, score_type, score_value, comment, created_at, updated_at)
VALUES
(1,  3, 1, 2, 1, 'SEMESTER_1', 'REGULAR',  8.5, 'Làm bài tốt',       NOW(), NOW()),
(2,  3, 1, 2, 1, 'SEMESTER_1', 'REGULAR',  7.0, 'Cần cải thiện',     NOW(), NOW()),
(3,  3, 1, 2, 1, 'SEMESTER_1', 'MIDTERM',  8.0, 'Làm bài chắc chắn', NOW(), NOW()),
(4,  3, 1, 2, 1, 'SEMESTER_1', 'FINAL',    8.5, 'Xuất sắc',          NOW(), NOW()),
-- Văn
(5,  3, 2, 2, 1, 'SEMESTER_1', 'REGULAR',  7.5, NULL,                 NOW(), NOW()),
(6,  3, 2, 2, 1, 'SEMESTER_1', 'REGULAR',  8.0, NULL,                 NOW(), NOW()),
(7,  3, 2, 2, 1, 'SEMESTER_1', 'MIDTERM',  7.0, NULL,                 NOW(), NOW()),
(8,  3, 2, 2, 1, 'SEMESTER_1', 'FINAL',    7.5, NULL,                 NOW(), NOW()),
-- Tiếng Anh
(9,  3, 3, 2, 1, 'SEMESTER_1', 'REGULAR',  9.0, 'Rất tốt',           NOW(), NOW()),
(10, 3, 3, 2, 1, 'SEMESTER_1', 'REGULAR',  9.5, 'Xuất sắc',          NOW(), NOW()),
(11, 3, 3, 2, 1, 'SEMESTER_1', 'MIDTERM',  9.0, NULL,                 NOW(), NOW()),
(12, 3, 3, 2, 1, 'SEMESTER_1', 'FINAL',    9.5, NULL,                 NOW(), NOW()),
-- Vật lý
(13, 3, 4, 2, 1, 'SEMESTER_1', 'REGULAR',  6.5, NULL,                 NOW(), NOW()),
(14, 3, 4, 2, 1, 'SEMESTER_1', 'REGULAR',  7.0, NULL,                 NOW(), NOW()),
(15, 3, 4, 2, 1, 'SEMESTER_1', 'MIDTERM',  6.5, NULL,                 NOW(), NOW()),
(16, 3, 4, 2, 1, 'SEMESTER_1', 'FINAL',    7.0, NULL,                 NOW(), NOW()),
-- Hóa học
(17, 3, 5, 2, 1, 'SEMESTER_1', 'REGULAR',  7.0, NULL,                 NOW(), NOW()),
(18, 3, 5, 2, 1, 'SEMESTER_1', 'REGULAR',  6.5, NULL,                 NOW(), NOW()),
(19, 3, 5, 2, 1, 'SEMESTER_1', 'MIDTERM',  7.5, NULL,                 NOW(), NOW()),
(20, 3, 5, 2, 1, 'SEMESTER_1', 'FINAL',    8.0, NULL,                 NOW(), NOW()),
-- Sinh học  
(21, 3, 6, 2, 1, 'SEMESTER_1', 'REGULAR',  8.0, NULL,                 NOW(), NOW()),
(22, 3, 6, 2, 1, 'SEMESTER_1', 'REGULAR',  8.5, NULL,                 NOW(), NOW()),
(23, 3, 6, 2, 1, 'SEMESTER_1', 'MIDTERM',  8.0, NULL,                 NOW(), NOW()),
(24, 3, 6, 2, 1, 'SEMESTER_1', 'FINAL',    8.5, NULL,                 NOW(), NOW()),

-- === HỌC KỲ 2 ===
-- Toán
(25, 3, 1, 2, 1, 'SEMESTER_2', 'REGULAR',  8.0, NULL,                 NOW(), NOW()),
(26, 3, 1, 2, 1, 'SEMESTER_2', 'REGULAR',  8.5, NULL,                 NOW(), NOW()),
(27, 3, 1, 2, 1, 'SEMESTER_2', 'MIDTERM',  8.5, NULL,                 NOW(), NOW()),
(28, 3, 1, 2, 1, 'SEMESTER_2', 'FINAL',    9.0, NULL,                 NOW(), NOW()),
-- Tiếng Anh
(29, 3, 3, 2, 1, 'SEMESTER_2', 'REGULAR',  9.5, NULL,                 NOW(), NOW()),
(30, 3, 3, 2, 1, 'SEMESTER_2', 'REGULAR', 10.0, NULL,                 NOW(), NOW()),
(31, 3, 3, 2, 1, 'SEMESTER_2', 'MIDTERM',  9.0, NULL,                 NOW(), NOW()),
(32, 3, 3, 2, 1, 'SEMESTER_2', 'FINAL',    9.5, NULL,                 NOW(), NOW()),
-- Vật lý (điểm thấp để demo màu đỏ)
(33, 3, 4, 2, 1, 'SEMESTER_2', 'REGULAR',  4.5, 'Cần cố gắng hơn',   NOW(), NOW()),
(34, 3, 4, 2, 1, 'SEMESTER_2', 'REGULAR',  5.0, NULL,                 NOW(), NOW()),
(35, 3, 4, 2, 1, 'SEMESTER_2', 'MIDTERM',  4.0, NULL,                 NOW(), NOW()),
(36, 3, 4, 2, 1, 'SEMESTER_2', 'FINAL',    5.5, NULL,                 NOW(), NOW());

-- =============================================================
-- 9. ATTENDANCE – tháng 3/2026
-- =============================================================
INSERT IGNORE INTO attendance
  (id, student_id, class_id, subject_id, teacher_id, schedule_id, attendance_date, status, note, created_at, updated_at)
VALUES
-- Tuần 17-21/03/2026
(1,  3, 1, 1, 2, 1,  '2026-03-17', 'PRESENT', NULL,                     NOW(), NOW()),
(2,  3, 1, 2, 2, 2,  '2026-03-17', 'PRESENT', NULL,                     NOW(), NOW()),
(3,  3, 1, 3, 2, 3,  '2026-03-18', 'LATE',    'Đến muộn 15 phút',       NOW(), NOW()),
(4,  3, 1, 4, 2, 4,  '2026-03-18', 'PRESENT', NULL,                     NOW(), NOW()),
(5,  3, 1, 5, 2, 5,  '2026-03-19', 'PRESENT', NULL,                     NOW(), NOW()),
(6,  3, 1, 1, 2, 6,  '2026-03-19', 'PRESENT', NULL,                     NOW(), NOW()),
(7,  3, 1, 6, 2, 7,  '2026-03-20', 'ABSENT',  'Không phép',             NOW(), NOW()),
(8,  3, 1, 7, 2, 8,  '2026-03-20', 'EXCUSED', 'Nghỉ có phép - xin nghỉ', NOW(), NOW()),
(9,  3, 1, 8, 2, 9,  '2026-03-21', 'PRESENT', NULL,                     NOW(), NOW()),
(10, 3, 1, 2, 2, 10, '2026-03-21', 'PRESENT', NULL,                     NOW(), NOW()),
-- Tuần 10-14/03/2026
(11, 3, 1, 1, 2, NULL, '2026-03-10', 'PRESENT', NULL, NOW(), NOW()),
(12, 3, 1, 2, 2, NULL, '2026-03-10', 'PRESENT', NULL, NOW(), NOW()),
(13, 3, 1, 3, 2, NULL, '2026-03-11', 'PRESENT', NULL, NOW(), NOW()),
(14, 3, 1, 4, 2, NULL, '2026-03-11', 'ABSENT',  'Ốm', NOW(), NOW()),
(15, 3, 1, 5, 2, NULL, '2026-03-12', 'PRESENT', NULL, NOW(), NOW()),
(16, 3, 1, 1, 2, NULL, '2026-03-12', 'PRESENT', NULL, NOW(), NOW()),
(17, 3, 1, 6, 2, NULL, '2026-03-13', 'LATE',    'Xe hỏng', NOW(), NOW()),
(18, 3, 1, 7, 2, NULL, '2026-03-13', 'PRESENT', NULL, NOW(), NOW()),
(19, 3, 1, 8, 2, NULL, '2026-03-14', 'PRESENT', NULL, NOW(), NOW()),
(20, 3, 1, 2, 2, NULL, '2026-03-14', 'PRESENT', NULL, NOW(), NOW()),
-- Tuần 03-07/03/2026
(21, 3, 1, 1, 2, NULL, '2026-03-03', 'PRESENT', NULL, NOW(), NOW()),
(22, 3, 1, 3, 2, NULL, '2026-03-04', 'PRESENT', NULL, NOW(), NOW()),
(23, 3, 1, 5, 2, NULL, '2026-03-05', 'EXCUSED', 'Họp gia đình', NOW(), NOW()),
(24, 3, 1, 6, 2, NULL, '2026-03-06', 'PRESENT', NULL, NOW(), NOW()),
(25, 3, 1, 2, 2, NULL, '2026-03-07', 'PRESENT', NULL, NOW(), NOW()),
-- Tháng 2
(26, 3, 1, 1, 2, NULL, '2026-02-24', 'PRESENT', NULL, NOW(), NOW()),
(27, 3, 1, 2, 2, NULL, '2026-02-25', 'ABSENT',  'Không phép', NOW(), NOW()),
(28, 3, 1, 3, 2, NULL, '2026-02-26', 'PRESENT', NULL, NOW(), NOW());

-- =============================================================
-- 10. ANNOUNCEMENTS (Thông báo lớp 10A1)
-- =============================================================
INSERT IGNORE INTO announcements (id, class_id, teacher_id, title, content, created_at, updated_at) VALUES
(1, 1, 2,
 'Lịch kiểm tra giữa kỳ 2 – Năm học 2025-2026',
 'Các em học sinh lớp 10A1 chú ý:\n\n📅 Lịch kiểm tra giữa kỳ 2 như sau:\n- Thứ 2 (30/03): Toán\n- Thứ 3 (31/03): Ngữ Văn\n- Thứ 4 (01/04): Tiếng Anh\n- Thứ 5 (02/04): Vật Lý + Hóa Học\n- Thứ 6 (03/04): Sinh Học\n\nCác em cần mang đầy đủ bút thước, KHÔNG sử dụng điện thoại trong giờ kiểm tra.',
 DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),

(2, 1, 2,
 'Họp phụ huynh học kỳ 2 – Ngày 28/03/2026',
 'Kính gửi quý Phụ huynh học sinh lớp 10A1,\n\nNhà trường trân trọng thông báo tổ chức buổi họp phụ huynh học kỳ 2 vào:\n\n🗓 Thứ Bảy, ngày 28/03/2026\n⏰ 08:00 – 10:30\n📍 Phòng hội trường A – Tầng 2\n\nNội dung: Đánh giá kết quả HK1, kế hoạch HK2 và kiểm tra cuối năm.\n\nKính mong quý Phụ huynh sắp xếp thời gian tham dự đầy đủ.',
 DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),

(3, 1, 2,
 'Nhắc nhở nộp học phí học kỳ 2',
 'Các em học sinh và Phụ huynh chú ý:\n\n💰 Hạn nộp học phí học kỳ 2 là ngày 31/03/2026.\n\nPhụ phí chưa nộp sẽ bị tính phụ phí 0.5%/ngày.\n\nCác hình thức nộp:\n✅ Chuyển khoản ngân hàng\n✅ Nộp trực tiếp tại phòng tài vụ (T2-T6: 7:30-11:00)\n✅ Thanh toán qua VNPay trên app\n\nMọi thắc mắc liên hệ: 0901 000 009',
 DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),

(4, 1, 2,
 'Kết quả thi học sinh giỏi cấp trường',
 'Chúc mừng các em đã đạt giải trong kỳ thi Học sinh giỏi cấp trường năm 2026:\n\n🥇 Giải Nhất Toán: Nguyễn Văn An (10A1)\n🥈 Giải Nhì Tiếng Anh: Nguyễn Văn An (10A1)\n\nNhà trường và lớp 10A1 rất tự hào. Tiếp tục phát huy các em nhé! 🎉',
 DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY));

-- =============================================================
-- 11. LEAVE REQUESTS (Đơn xin nghỉ)
-- =============================================================
INSERT IGNORE INTO leave_requests
  (id, student_id, class_id, from_date, to_date, reason, status, reviewed_by, response_note, reviewed_at, created_at, updated_at)
VALUES
-- Đơn đã được duyệt (T2 20/03)
(1, 3, 1,
 '2026-03-20', '2026-03-20',
 'Em bị sốt, cần ở nhà nghỉ ngơi. Có giấy xác nhận của bác sĩ.',
 'APPROVED',
 2,
 'Đã xác nhận. Chúc em mau khỏe.',
 DATE_SUB(NOW(), INTERVAL 5 DAY),
 DATE_SUB(NOW(), INTERVAL 6 DAY),
 DATE_SUB(NOW(), INTERVAL 6 DAY)),

-- Đơn đang chờ duyệt
(2, 3, 1,
 '2026-03-25', '2026-03-25',
 'Gia đình em có việc đột xuất, em xin phép nghỉ 1 buổi chiều.',
 'PENDING',
 NULL, NULL, NULL,
 DATE_SUB(NOW(), INTERVAL 1 DAY),
 DATE_SUB(NOW(), INTERVAL 1 DAY)),

-- Đơn bị từ chối
(3, 3, 1,
 '2026-03-15', '2026-03-15',
 'Em muốn nghỉ để đi dự tiệc sinh nhật bạn.',
 'REJECTED',
 2,
 'Lý do chưa phù hợp. Đề nghị không nghỉ học.',
 DATE_SUB(NOW(), INTERVAL 8 DAY),
 DATE_SUB(NOW(), INTERVAL 9 DAY),
 DATE_SUB(NOW(), INTERVAL 9 DAY));

-- =============================================================
-- 12. TUITION PAYMENTS (Học phí)
-- =============================================================
INSERT IGNORE INTO tuition_payments
  (id, student_id, class_id, amount, due_date, paid_date, status, payment_method, vnp_txn_ref, order_info, created_at, updated_at)
VALUES
-- HK1: đã đóng
(1, 3, 1,
 3500000.00,
 '2025-09-30',
 '2025-09-25',
 'PAID',
 'VNPAY',
 'TXN20250925001',
 'Hoc phi HK1 - 10A1 - Nguyen Van An',
 '2025-09-25 08:30:00', '2025-09-25 08:30:00'),

-- HK2: chưa đóng, sắp quá hạn
(2, 3, 1,
 3500000.00,
 '2026-03-31',
 NULL,
 'UNPAID',
 NULL,
 NULL,
 'Hoc phi HK2 - 10A1 - Nguyen Van An',
 NOW(), NOW()),

-- Phí hoạt động ngoại khóa: quá hạn
(3, 3, 1,
 500000.00,
 '2026-02-28',
 NULL,
 'OVERDUE',
 NULL,
 NULL,
 'Phi hoat dong ngoai khoa - T2/2026',
 DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY));

-- =============================================================
-- 13. MESSAGES (Tin nhắn)
--    Cuộc hội thoại giữa Cô Bích (2) và Học sinh An (3)
--    Cuộc hội thoại giữa Cô Bích (2) và PH Bình (4)
-- =============================================================
INSERT IGNORE INTO messages
  (id, sender_id, receiver_id, content, is_read, created_at, updated_at)
VALUES
-- Cô Bích → Học sinh An
(1, 2, 3,
 'An ơi, em chú ý ôn bài chương 3 Vật lý nhé, tuần sau kiểm tra.',
 TRUE, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),

-- Học sinh An → Cô Bích
(2, 3, 2,
 'Dạ vâng thưa cô! Em sẽ ôn tập kỹ ạ.',
 TRUE, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),

-- Cô Bích → Học sinh An
(3, 2, 3,
 'Bài tập về nhà trang 87 em làm chưa? Nộp trước 8h sáng mai nhé.',
 TRUE, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),

-- Học sinh An → Cô Bích
(4, 3, 2,
 'Dạ em làm xong rồi ạ, em sẽ nộp đúng giờ ạ.',
 FALSE, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),

-- Cô Bích → PH Bình
(5, 2, 4,
 'Kính chào Phụ huynh, tôi là cô Bích GVCN lớp 10A1. Tuần này bạn An có vắng 1 buổi không phép, mong gia đình nhắc nhở ạ.',
 TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),

-- PH Bình → Cô Bích
(6, 4, 2,
 'Cảm ơn cô đã thông báo. Hôm đó cháu ốm ạ. Tôi sẽ nhắc cháu xin phép trước ạ.',
 TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),

-- Cô Bích → PH Bình
(7, 2, 4,
 'Anh nhớ nhắc An nộp học phí HK2 trước 31/03 ạ, sắp tới hạn rồi.',
 FALSE, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY));

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
-- TÓM TẮT TÀI KHOẢN DEMO
-- =============================================================
-- | Role    | Username       | Password     | Họ tên             |
-- |---------|----------------|--------------|--------------------|
-- | Admin   | admin          | Password@123 | Nguyễn Quản Trị    |
-- | Giáo viên| teacher_bich  | Password@123 | Trần Thị Bích      |
-- | Học sinh| student_an     | Password@123 | Nguyễn Văn An      |
-- | Phụ huynh| parent_binh   | Password@123 | Nguyễn Văn Bình    |
-- =============================================================
-- Lưu ý: hash trên được tạo bằng BCrypt cost 12 cho "Password@123"
-- Nếu không đăng nhập được, chạy lệnh sau để tạo lại hash:
--   https://bcrypt-generator.com/ với value "Password@123", rounds 12
-- Sau đó UPDATE users SET password='<hash mới>' WHERE id IN (1,2,3,4);
-- =============================================================
