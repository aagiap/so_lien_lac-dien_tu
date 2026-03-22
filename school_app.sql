/*
Navicat MySQL Data Transfer

Source Server         : localhost mysql
Source Server Version : 80044
Source Host           : localhost:3306
Source Database       : school_app

Target Server Type    : MYSQL
Target Server Version : 80044
File Encoding         : 65001

Date: 2026-03-22 18:32:04
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `announcements`
-- ----------------------------
DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `content` tinytext NOT NULL,
  `title` varchar(200) NOT NULL,
  `class_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK3n8i71lr49vv058cita1b90m7` (`class_id`),
  KEY `FKoiiu7ig5rie7yv0a0ny32auus` (`teacher_id`),
  CONSTRAINT `FK3n8i71lr49vv058cita1b90m7` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`),
  CONSTRAINT `FKoiiu7ig5rie7yv0a0ny32auus` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of announcements
-- ----------------------------
INSERT INTO `announcements` VALUES ('1', '2026-03-20 20:20:19.000000', '2026-03-20 20:20:19.000000', 'Các em học sinh lớp 10A1 chú ý:\n\n? Lịch kiểm tra giữa kỳ 2 như sau:\n- Thứ 2 (30/03): Toán\n- Thứ 3 (31/03): Ngữ Văn\n- Thứ 4 (01/04): Tiếng Anh\n- Thứ 5 (02/04): Vật Lý + Hóa Học\n- Thứ 6 (03/04): Sinh Học\n\nCác em cầ', 'Lịch kiểm tra giữa kỳ 2 – Năm học 2025-2026', '1', '2');
INSERT INTO `announcements` VALUES ('2', '2026-03-19 20:20:19.000000', '2026-03-19 20:20:19.000000', 'Kính gửi quý Phụ huynh học sinh lớp 10A1,\n\nNhà trường trân trọng thông báo tổ chức buổi họp phụ huynh học kỳ 2 vào:\n\n? Thứ Bảy, ngày 28/03/2026\n⏰ 08:00 – 10:30\n? Phòng hội trường A – Tầng 2\n\nNội dung:', 'Họp phụ huynh học kỳ 2 – Ngày 28/03/2026', '1', '2');
INSERT INTO `announcements` VALUES ('3', '2026-03-18 20:20:19.000000', '2026-03-18 20:20:19.000000', 'Các em học sinh và Phụ huynh chú ý:\n\n? Hạn nộp học phí học kỳ 2 là ngày 31/03/2026.\n\nPhụ phí chưa nộp sẽ bị tính phụ phí 0.5%/ngày.\n\nCác hình thức nộp:\n✅ Chuyển khoản ngân hàng\n✅ Nộp trực tiếp tạ', 'Nhắc nhở nộp học phí học kỳ 2', '1', '2');
INSERT INTO `announcements` VALUES ('4', '2026-03-16 20:20:19.000000', '2026-03-16 20:20:19.000000', 'Chúc mừng các em đã đạt giải trong kỳ thi Học sinh giỏi cấp trường năm 2026:\n\n? Giải Nhất Toán: Nguyễn Văn An (10A1)\n? Giải Nhì Tiếng Anh: Nguyễn Văn An (10A1)\n\nNhà trường và lớp 10A1 rất tự hào. Tiếp t', 'Kết quả thi học sinh giỏi cấp trường', '1', '2');
INSERT INTO `announcements` VALUES ('5', '2026-03-22 00:03:06.991719', '2026-03-22 00:03:06.991719', 'không học chết đòn với t', 'học đi cu', '1', '2');
INSERT INTO `announcements` VALUES ('6', '2026-03-22 18:03:19.927049', '2026-03-22 18:03:19.927049', 'mai tao kiểm tra', 'học đi các cháu', '1', '2');

-- ----------------------------
-- Table structure for `attendance`
-- ----------------------------
DROP TABLE IF EXISTS `attendance`;
CREATE TABLE `attendance` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `attendance_date` date NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `status` enum('ABSENT','EXCUSED','LATE','PRESENT') NOT NULL,
  `schedule_id` bigint DEFAULT NULL,
  `class_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `subject_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK3ubfa45l2ve7k80jlxkwh5ht5` (`schedule_id`),
  KEY `FKrx58locko31i5sa3goghxssli` (`class_id`),
  KEY `FK80qpvlsg0xpmw80bnk64avvou` (`student_id`),
  KEY `FKcjg1qkkmmy4dtktcdug457x4p` (`subject_id`),
  KEY `FK20vdyuqiwk2wg563vmy4rlsne` (`teacher_id`),
  CONSTRAINT `FK20vdyuqiwk2wg563vmy4rlsne` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FK3ubfa45l2ve7k80jlxkwh5ht5` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`),
  CONSTRAINT `FK80qpvlsg0xpmw80bnk64avvou` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKcjg1qkkmmy4dtktcdug457x4p` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`),
  CONSTRAINT `FKrx58locko31i5sa3goghxssli` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of attendance
-- ----------------------------
INSERT INTO `attendance` VALUES ('1', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-17', null, 'PRESENT', '1', '1', '3', '1', '2');
INSERT INTO `attendance` VALUES ('2', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-17', null, 'PRESENT', '2', '1', '3', '2', '2');
INSERT INTO `attendance` VALUES ('3', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-18', 'Đến muộn 15 phút', 'LATE', '3', '1', '3', '3', '2');
INSERT INTO `attendance` VALUES ('4', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-18', null, 'PRESENT', '4', '1', '3', '4', '2');
INSERT INTO `attendance` VALUES ('5', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-19', null, 'PRESENT', '5', '1', '3', '5', '2');
INSERT INTO `attendance` VALUES ('6', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-19', null, 'PRESENT', '6', '1', '3', '1', '2');
INSERT INTO `attendance` VALUES ('7', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-20', 'Không phép', 'ABSENT', '7', '1', '3', '6', '2');
INSERT INTO `attendance` VALUES ('8', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-20', 'Nghỉ có phép - xin nghỉ', 'EXCUSED', '8', '1', '3', '7', '2');
INSERT INTO `attendance` VALUES ('9', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-21', null, 'PRESENT', '9', '1', '3', '8', '2');
INSERT INTO `attendance` VALUES ('10', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-21', null, 'PRESENT', '10', '1', '3', '2', '2');
INSERT INTO `attendance` VALUES ('11', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-10', null, 'PRESENT', null, '1', '3', '1', '2');
INSERT INTO `attendance` VALUES ('12', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-10', null, 'PRESENT', null, '1', '3', '2', '2');
INSERT INTO `attendance` VALUES ('13', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-11', null, 'PRESENT', null, '1', '3', '3', '2');
INSERT INTO `attendance` VALUES ('14', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-11', 'Ốm', 'ABSENT', null, '1', '3', '4', '2');
INSERT INTO `attendance` VALUES ('15', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-12', null, 'PRESENT', null, '1', '3', '5', '2');
INSERT INTO `attendance` VALUES ('16', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-12', null, 'PRESENT', null, '1', '3', '1', '2');
INSERT INTO `attendance` VALUES ('17', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-13', 'Xe hỏng', 'LATE', null, '1', '3', '6', '2');
INSERT INTO `attendance` VALUES ('18', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-13', null, 'PRESENT', null, '1', '3', '7', '2');
INSERT INTO `attendance` VALUES ('19', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-14', null, 'PRESENT', null, '1', '3', '8', '2');
INSERT INTO `attendance` VALUES ('20', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-14', null, 'PRESENT', null, '1', '3', '2', '2');
INSERT INTO `attendance` VALUES ('21', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-03', null, 'PRESENT', null, '1', '3', '1', '2');
INSERT INTO `attendance` VALUES ('22', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-04', null, 'PRESENT', null, '1', '3', '3', '2');
INSERT INTO `attendance` VALUES ('23', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-05', 'Họp gia đình', 'EXCUSED', null, '1', '3', '5', '2');
INSERT INTO `attendance` VALUES ('24', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-06', null, 'PRESENT', null, '1', '3', '6', '2');
INSERT INTO `attendance` VALUES ('25', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-03-07', null, 'PRESENT', null, '1', '3', '2', '2');
INSERT INTO `attendance` VALUES ('26', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-02-24', null, 'PRESENT', null, '1', '3', '1', '2');
INSERT INTO `attendance` VALUES ('27', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-02-25', 'Không phép', 'ABSENT', null, '1', '3', '2', '2');
INSERT INTO `attendance` VALUES ('28', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '2026-02-26', null, 'PRESENT', null, '1', '3', '3', '2');

-- ----------------------------
-- Table structure for `classes`
-- ----------------------------
DROP TABLE IF EXISTS `classes`;
CREATE TABLE `classes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `grade_level` int NOT NULL,
  `class_name` varchar(100) NOT NULL,
  `school_year` varchar(20) NOT NULL,
  `homeroom_teacher_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKsunn99t67x9n0ni828ihrjvy5` (`homeroom_teacher_id`),
  CONSTRAINT `FKsunn99t67x9n0ni828ihrjvy5` FOREIGN KEY (`homeroom_teacher_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of classes
-- ----------------------------
INSERT INTO `classes` VALUES ('1', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '10', '10A1', '2025-2026', '2');

-- ----------------------------
-- Table structure for `class_members`
-- ----------------------------
DROP TABLE IF EXISTS `class_members`;
CREATE TABLE `class_members` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `member_role` enum('PARENT','STUDENT','TEACHER') NOT NULL,
  `linked_student_id` bigint DEFAULT NULL,
  `class_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKhku7f5adp4intxq6jwlree4vu` (`linked_student_id`),
  KEY `FK72on5wi5b6ba3ciup6o7ap1h1` (`class_id`),
  KEY `FKd3vflmmfvl81ytnmvixv5iiky` (`user_id`),
  CONSTRAINT `FK72on5wi5b6ba3ciup6o7ap1h1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`),
  CONSTRAINT `FKd3vflmmfvl81ytnmvixv5iiky` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKhku7f5adp4intxq6jwlree4vu` FOREIGN KEY (`linked_student_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of class_members
-- ----------------------------
INSERT INTO `class_members` VALUES ('1', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'TEACHER', null, '1', '2');
INSERT INTO `class_members` VALUES ('2', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'STUDENT', null, '1', '3');
INSERT INTO `class_members` VALUES ('3', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'PARENT', '3', '1', '4');

-- ----------------------------
-- Table structure for `leave_requests`
-- ----------------------------
DROP TABLE IF EXISTS `leave_requests`;
CREATE TABLE `leave_requests` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `from_date` date NOT NULL,
  `reason` tinytext NOT NULL,
  `response_note` varchar(255) DEFAULT NULL,
  `reviewed_at` datetime(6) DEFAULT NULL,
  `status` enum('APPROVED','PENDING','REJECTED') NOT NULL,
  `to_date` date NOT NULL,
  `reviewed_by` bigint DEFAULT NULL,
  `class_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKm6br6lc65loui2q8s547hqyv7` (`reviewed_by`),
  KEY `FK3f9tbb0j0g9emsr4pd8hjsn1j` (`class_id`),
  KEY `FK9fdtjpj0jbryjkbkmscepov4p` (`student_id`),
  CONSTRAINT `FK3f9tbb0j0g9emsr4pd8hjsn1j` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`),
  CONSTRAINT `FK9fdtjpj0jbryjkbkmscepov4p` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKm6br6lc65loui2q8s547hqyv7` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of leave_requests
-- ----------------------------
INSERT INTO `leave_requests` VALUES ('1', '2026-03-15 20:20:19.000000', '2026-03-15 20:20:19.000000', '2026-03-20', 'Em bị sốt, cần ở nhà nghỉ ngơi. Có giấy xác nhận của bác sĩ.', 'Đã xác nhận. Chúc em mau khỏe.', '2026-03-16 20:20:19.000000', 'APPROVED', '2026-03-20', '2', '1', '3');
INSERT INTO `leave_requests` VALUES ('2', '2026-03-20 20:20:19.000000', '2026-03-21 22:37:23.201196', '2026-03-25', 'Gia đình em có việc đột xuất, em xin phép nghỉ 1 buổi chiều.', null, '2026-03-21 22:37:23.155490', 'REJECTED', '2026-03-25', '2', '1', '3');
INSERT INTO `leave_requests` VALUES ('3', '2026-03-12 20:20:19.000000', '2026-03-12 20:20:19.000000', '2026-03-15', 'Em muốn nghỉ để đi dự tiệc sinh nhật bạn.', 'Lý do chưa phù hợp. Đề nghị không nghỉ học.', '2026-03-13 20:20:19.000000', 'REJECTED', '2026-03-15', '2', '1', '3');
INSERT INTO `leave_requests` VALUES ('4', '2026-03-21 22:02:46.648482', '2026-03-21 22:37:27.505185', '2026-03-21', 'thich', null, '2026-03-21 22:37:27.501155', 'APPROVED', '2026-03-21', '2', '1', '3');
INSERT INTO `leave_requests` VALUES ('5', '2026-03-22 18:05:10.007996', '2026-03-22 18:05:16.344566', '2026-03-22', 'thích', 'Đã duyệt bởi Giáo viên/Admin.', '2026-03-22 18:05:16.340566', 'APPROVED', '2026-03-22', '2', '1', '3');

-- ----------------------------
-- Table structure for `messages`
-- ----------------------------
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `content` varchar(1000) NOT NULL,
  `is_read` bit(1) NOT NULL,
  `receiver_id` bigint NOT NULL,
  `sender_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKt05r0b6n0iis8u7dfna4xdh73` (`receiver_id`),
  KEY `FK4ui4nnwntodh6wjvck53dbk9m` (`sender_id`),
  CONSTRAINT `FK4ui4nnwntodh6wjvck53dbk9m` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKt05r0b6n0iis8u7dfna4xdh73` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of messages
-- ----------------------------
INSERT INTO `messages` VALUES ('1', '2026-03-18 20:20:19.000000', '2026-03-18 20:20:19.000000', 'An ơi, em chú ý ôn bài chương 3 Vật lý nhé, tuần sau kiểm tra.', '', '3', '2');
INSERT INTO `messages` VALUES ('2', '2026-03-18 20:20:19.000000', '2026-03-18 20:20:19.000000', 'Dạ vâng thưa cô! Em sẽ ôn tập kỹ ạ.', '', '2', '3');
INSERT INTO `messages` VALUES ('3', '2026-03-20 20:20:19.000000', '2026-03-20 20:20:19.000000', 'Bài tập về nhà trang 87 em làm chưa? Nộp trước 8h sáng mai nhé.', '', '3', '2');
INSERT INTO `messages` VALUES ('4', '2026-03-20 20:20:19.000000', '2026-03-20 20:20:19.000000', 'Dạ em làm xong rồi ạ, em sẽ nộp đúng giờ ạ.', '', '2', '3');
INSERT INTO `messages` VALUES ('5', '2026-03-19 20:20:19.000000', '2026-03-19 20:20:19.000000', 'Kính chào Phụ huynh, tôi là cô Bích GVCN lớp 10A1. Tuần này bạn An có vắng 1 buổi không phép, mong gia đình nhắc nhở ạ.', '', '4', '2');
INSERT INTO `messages` VALUES ('6', '2026-03-19 20:20:19.000000', '2026-03-19 20:20:19.000000', 'Cảm ơn cô đã thông báo. Hôm đó cháu ốm ạ. Tôi sẽ nhắc cháu xin phép trước ạ.', '', '2', '4');
INSERT INTO `messages` VALUES ('7', '2026-03-20 20:20:19.000000', '2026-03-20 20:20:19.000000', 'Anh nhớ nhắc An nộp học phí HK2 trước 31/03 ạ, sắp tới hạn rồi.', '', '4', '2');
INSERT INTO `messages` VALUES ('8', '2026-03-21 22:01:59.371528', '2026-03-21 22:01:59.371528', 'Bo oi', '', '4', '3');
INSERT INTO `messages` VALUES ('9', '2026-03-21 22:06:05.745962', '2026-03-21 22:06:05.745962', 'Hi em', '', '3', '2');
INSERT INTO `messages` VALUES ('10', '2026-03-21 22:11:16.917832', '2026-03-21 22:11:16.917832', 'Alo', '', '2', '3');
INSERT INTO `messages` VALUES ('11', '2026-03-21 22:11:20.522816', '2026-03-21 22:11:20.522816', 'd', '', '2', '3');
INSERT INTO `messages` VALUES ('12', '2026-03-21 23:28:55.560843', '2026-03-21 23:28:55.560843', 'em ơi', '', '3', '2');
INSERT INTO `messages` VALUES ('13', '2026-03-21 23:29:22.036188', '2026-03-21 23:29:22.036188', 'alo', '', '3', '2');
INSERT INTO `messages` VALUES ('14', '2026-03-21 23:33:22.731164', '2026-03-21 23:33:22.731164', 'em', '', '3', '2');
INSERT INTO `messages` VALUES ('15', '2026-03-21 23:51:17.280627', '2026-03-21 23:51:17.280627', 'em ơi', '', '3', '2');
INSERT INTO `messages` VALUES ('16', '2026-03-22 00:00:28.285628', '2026-03-22 00:00:28.285628', 'rep đi em', '', '3', '2');
INSERT INTO `messages` VALUES ('17', '2026-03-22 17:09:07.690172', '2026-03-22 17:09:07.690172', 'E day', '', '2', '3');
INSERT INTO `messages` VALUES ('18', '2026-03-22 17:09:29.470027', '2026-03-22 17:09:29.470027', 'alo', '', '3', '2');
INSERT INTO `messages` VALUES ('19', '2026-03-22 17:28:53.831580', '2026-03-22 17:28:53.831580', 'em ơi', '', '3', '2');
INSERT INTO `messages` VALUES ('20', '2026-03-22 17:28:59.794062', '2026-03-22 17:28:59.794062', 'em ơi', '', '3', '2');
INSERT INTO `messages` VALUES ('21', '2026-03-22 17:29:06.085749', '2026-03-22 17:29:06.085749', 'alo', '', '3', '2');
INSERT INTO `messages` VALUES ('22', '2026-03-22 17:29:15.875019', '2026-03-22 17:29:15.875019', 'Emday', '', '2', '3');
INSERT INTO `messages` VALUES ('23', '2026-03-22 18:01:17.965351', '2026-03-22 18:01:17.965351', 'em ơi', '', '3', '2');
INSERT INTO `messages` VALUES ('24', '2026-03-22 18:01:38.743374', '2026-03-22 18:01:38.743374', 'em ơi', '', '3', '2');
INSERT INTO `messages` VALUES ('25', '2026-03-22 18:01:50.971368', '2026-03-22 18:01:50.971368', 'Em đây', '', '2', '3');
INSERT INTO `messages` VALUES ('26', '2026-03-22 18:01:56.256259', '2026-03-22 18:01:56.256259', 'em ơi', '', '3', '2');
INSERT INTO `messages` VALUES ('27', '2026-03-22 18:04:34.538229', '2026-03-22 18:04:34.538229', 'ewe', '', '3', '2');
INSERT INTO `messages` VALUES ('28', '2026-03-22 18:04:54.971467', '2026-03-22 18:04:54.971467', 'đánh cho to đầu h', '', '3', '2');
INSERT INTO `messages` VALUES ('29', '2026-03-22 18:17:47.911862', '2026-03-22 18:17:47.911862', 'reo tao', '', '3', '2');
INSERT INTO `messages` VALUES ('30', '2026-03-22 18:17:54.810339', '2026-03-22 18:17:54.810339', 'tốt rồi', '', '3', '2');

-- ----------------------------
-- Table structure for `roles`
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` enum('ADMIN','PARENT','STUDENT','TEACHER') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKofx66keruapi6vyqpv6f2or37` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of roles
-- ----------------------------
INSERT INTO `roles` VALUES ('1', 'ADMIN');
INSERT INTO `roles` VALUES ('4', 'PARENT');
INSERT INTO `roles` VALUES ('3', 'STUDENT');
INSERT INTO `roles` VALUES ('2', 'TEACHER');

-- ----------------------------
-- Table structure for `schedule`
-- ----------------------------
DROP TABLE IF EXISTS `schedule`;
CREATE TABLE `schedule` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `end_time` time(6) NOT NULL,
  `lesson_date` date NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `start_time` time(6) NOT NULL,
  `class_id` bigint NOT NULL,
  `subject_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKr08uur02xmp7v8pi6qpfbo5n2` (`class_id`),
  KEY `FK5yrbco7c1qrljdaq59ogqen9o` (`subject_id`),
  KEY `FKqg83a35tfp7iv067qf82nwuj4` (`teacher_id`),
  CONSTRAINT `FK5yrbco7c1qrljdaq59ogqen9o` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`),
  CONSTRAINT `FKqg83a35tfp7iv067qf82nwuj4` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKr08uur02xmp7v8pi6qpfbo5n2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of schedule
-- ----------------------------
INSERT INTO `schedule` VALUES ('1', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '08:30:00.000000', '2026-03-17', null, 'P.201', '07:00:00.000000', '1', '1', '2');
INSERT INTO `schedule` VALUES ('2', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '10:30:00.000000', '2026-03-17', null, 'P.201', '09:00:00.000000', '1', '2', '2');
INSERT INTO `schedule` VALUES ('3', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '08:30:00.000000', '2026-03-18', null, 'P.203', '07:00:00.000000', '1', '3', '2');
INSERT INTO `schedule` VALUES ('4', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '10:30:00.000000', '2026-03-18', 'Thực hành', 'P.207', '09:00:00.000000', '1', '4', '2');
INSERT INTO `schedule` VALUES ('5', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '08:30:00.000000', '2026-03-19', 'Thí nghiệm hóa', 'PTN', '07:00:00.000000', '1', '5', '2');
INSERT INTO `schedule` VALUES ('6', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '10:30:00.000000', '2026-03-19', null, 'P.201', '09:00:00.000000', '1', '1', '2');
INSERT INTO `schedule` VALUES ('7', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '08:30:00.000000', '2026-03-20', null, 'P.205', '07:00:00.000000', '1', '6', '2');
INSERT INTO `schedule` VALUES ('8', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '10:30:00.000000', '2026-03-20', null, 'P.202', '09:00:00.000000', '1', '7', '2');
INSERT INTO `schedule` VALUES ('9', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '08:30:00.000000', '2026-03-21', null, 'P.204', '07:00:00.000000', '1', '8', '2');
INSERT INTO `schedule` VALUES ('10', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '10:30:00.000000', '2026-03-21', null, 'P.201', '09:00:00.000000', '1', '2', '2');

-- ----------------------------
-- Table structure for `scores`
-- ----------------------------
DROP TABLE IF EXISTS `scores`;
CREATE TABLE `scores` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `score_type` enum('FINAL','MIDTERM','REGULAR') NOT NULL,
  `score_value` decimal(4,2) NOT NULL,
  `semester` enum('SEMESTER_1','SEMESTER_2') NOT NULL,
  `class_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  `subject_id` bigint NOT NULL,
  `teacher_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKo32vpkl1ux0v4khlefcd7kcwp` (`class_id`),
  KEY `FKc6oaxi2w369gwbyjhroavxu09` (`student_id`),
  KEY `FK1aicois4dtfaxk4hshrs35yd4` (`subject_id`),
  KEY `FKk03uc5vyx6cblvu920qx3udl3` (`teacher_id`),
  CONSTRAINT `FK1aicois4dtfaxk4hshrs35yd4` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`),
  CONSTRAINT `FKc6oaxi2w369gwbyjhroavxu09` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKk03uc5vyx6cblvu920qx3udl3` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKo32vpkl1ux0v4khlefcd7kcwp` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of scores
-- ----------------------------
INSERT INTO `scores` VALUES ('1', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'Làm bài tốt', 'REGULAR', '8.50', 'SEMESTER_1', '1', '3', '1', '2');
INSERT INTO `scores` VALUES ('2', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'Cần cải thiện', 'REGULAR', '7.00', 'SEMESTER_1', '1', '3', '1', '2');
INSERT INTO `scores` VALUES ('3', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'Làm bài chắc chắn', 'MIDTERM', '8.00', 'SEMESTER_1', '1', '3', '1', '2');
INSERT INTO `scores` VALUES ('4', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'Xuất sắc', 'FINAL', '8.50', 'SEMESTER_1', '1', '3', '1', '2');
INSERT INTO `scores` VALUES ('5', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '7.50', 'SEMESTER_1', '1', '3', '2', '2');
INSERT INTO `scores` VALUES ('6', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '8.00', 'SEMESTER_1', '1', '3', '2', '2');
INSERT INTO `scores` VALUES ('7', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'MIDTERM', '7.00', 'SEMESTER_1', '1', '3', '2', '2');
INSERT INTO `scores` VALUES ('8', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'FINAL', '7.50', 'SEMESTER_1', '1', '3', '2', '2');
INSERT INTO `scores` VALUES ('9', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'Rất tốt', 'REGULAR', '9.00', 'SEMESTER_1', '1', '3', '3', '2');
INSERT INTO `scores` VALUES ('10', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'Xuất sắc', 'REGULAR', '9.50', 'SEMESTER_1', '1', '3', '3', '2');
INSERT INTO `scores` VALUES ('11', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'MIDTERM', '9.00', 'SEMESTER_1', '1', '3', '3', '2');
INSERT INTO `scores` VALUES ('12', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'FINAL', '9.50', 'SEMESTER_1', '1', '3', '3', '2');
INSERT INTO `scores` VALUES ('13', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '6.50', 'SEMESTER_1', '1', '3', '4', '2');
INSERT INTO `scores` VALUES ('14', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '7.00', 'SEMESTER_1', '1', '3', '4', '2');
INSERT INTO `scores` VALUES ('15', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'MIDTERM', '6.50', 'SEMESTER_1', '1', '3', '4', '2');
INSERT INTO `scores` VALUES ('16', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'FINAL', '7.00', 'SEMESTER_1', '1', '3', '4', '2');
INSERT INTO `scores` VALUES ('17', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '7.00', 'SEMESTER_1', '1', '3', '5', '2');
INSERT INTO `scores` VALUES ('18', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '6.50', 'SEMESTER_1', '1', '3', '5', '2');
INSERT INTO `scores` VALUES ('19', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'MIDTERM', '7.50', 'SEMESTER_1', '1', '3', '5', '2');
INSERT INTO `scores` VALUES ('20', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'FINAL', '8.00', 'SEMESTER_1', '1', '3', '5', '2');
INSERT INTO `scores` VALUES ('21', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '8.00', 'SEMESTER_1', '1', '3', '6', '2');
INSERT INTO `scores` VALUES ('22', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '8.50', 'SEMESTER_1', '1', '3', '6', '2');
INSERT INTO `scores` VALUES ('23', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'MIDTERM', '8.00', 'SEMESTER_1', '1', '3', '6', '2');
INSERT INTO `scores` VALUES ('24', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'FINAL', '8.50', 'SEMESTER_1', '1', '3', '6', '2');
INSERT INTO `scores` VALUES ('25', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '8.00', 'SEMESTER_2', '1', '3', '1', '2');
INSERT INTO `scores` VALUES ('26', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '8.50', 'SEMESTER_2', '1', '3', '1', '2');
INSERT INTO `scores` VALUES ('27', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'MIDTERM', '8.50', 'SEMESTER_2', '1', '3', '1', '2');
INSERT INTO `scores` VALUES ('28', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'FINAL', '9.00', 'SEMESTER_2', '1', '3', '1', '2');
INSERT INTO `scores` VALUES ('29', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '9.50', 'SEMESTER_2', '1', '3', '3', '2');
INSERT INTO `scores` VALUES ('30', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '10.00', 'SEMESTER_2', '1', '3', '3', '2');
INSERT INTO `scores` VALUES ('31', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'MIDTERM', '9.00', 'SEMESTER_2', '1', '3', '3', '2');
INSERT INTO `scores` VALUES ('32', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'FINAL', '9.50', 'SEMESTER_2', '1', '3', '3', '2');
INSERT INTO `scores` VALUES ('33', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'Cần cố gắng hơn', 'REGULAR', '4.50', 'SEMESTER_2', '1', '3', '4', '2');
INSERT INTO `scores` VALUES ('34', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'REGULAR', '5.00', 'SEMESTER_2', '1', '3', '4', '2');
INSERT INTO `scores` VALUES ('35', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'MIDTERM', '4.00', 'SEMESTER_2', '1', '3', '4', '2');
INSERT INTO `scores` VALUES ('36', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', null, 'FINAL', '5.50', 'SEMESTER_2', '1', '3', '4', '2');

-- ----------------------------
-- Table structure for `subjects`
-- ----------------------------
DROP TABLE IF EXISTS `subjects`;
CREATE TABLE `subjects` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `code` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKrg7x1lyii7kdyycw98d45vep5` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of subjects
-- ----------------------------
INSERT INTO `subjects` VALUES ('1', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'TOAN', 'Đại số, giải tích, hình học', 'Toán học');
INSERT INTO `subjects` VALUES ('2', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'VAN', 'Văn học Việt Nam và thế giới', 'Ngữ văn');
INSERT INTO `subjects` VALUES ('3', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'ANH', 'Giao tiếp và ngữ pháp tiếng Anh', 'Tiếng Anh');
INSERT INTO `subjects` VALUES ('4', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'LY', 'Cơ học, điện, quang học', 'Vật lý');
INSERT INTO `subjects` VALUES ('5', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'HOA', 'Hóa vô cơ và hữu cơ', 'Hóa học');
INSERT INTO `subjects` VALUES ('6', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'SINH', 'Sinh học tế bào, di truyền học', 'Sinh học');
INSERT INTO `subjects` VALUES ('7', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'SU', 'Lịch sử Việt Nam và thế giới', 'Lịch sử');
INSERT INTO `subjects` VALUES ('8', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', 'DIA', 'Địa lý tự nhiên và kinh tế xã hội', 'Địa lý');

-- ----------------------------
-- Table structure for `tuition_payments`
-- ----------------------------
DROP TABLE IF EXISTS `tuition_payments`;
CREATE TABLE `tuition_payments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `due_date` date NOT NULL,
  `order_info` varchar(255) DEFAULT NULL,
  `paid_date` date DEFAULT NULL,
  `payment_method` enum('BANK_TRANSFER','CASH','VNPAY') DEFAULT NULL,
  `status` enum('OVERDUE','PAID','PENDING','UNPAID') NOT NULL,
  `vnp_txn_ref` varchar(100) DEFAULT NULL,
  `class_id` bigint NOT NULL,
  `student_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKde15a82caaqkt35c7q05ego7e` (`vnp_txn_ref`),
  KEY `FKhq17hxmev8u9wfw97m0xdrpkg` (`class_id`),
  KEY `FK5snw1f8epsn7sdiin5xkjpmu` (`student_id`),
  CONSTRAINT `FK5snw1f8epsn7sdiin5xkjpmu` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`),
  CONSTRAINT `FKhq17hxmev8u9wfw97m0xdrpkg` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of tuition_payments
-- ----------------------------
INSERT INTO `tuition_payments` VALUES ('1', '2025-09-25 08:30:00.000000', '2026-03-22 18:10:17.487697', '3500000.00', '2025-09-30', 'Hoc phi HK1 - 10A1 - Nguyen Van An', '2025-09-25', 'VNPAY', 'PENDING', 'TXN20250925001', '1', '3');
INSERT INTO `tuition_payments` VALUES ('2', '2026-03-21 20:20:19.000000', '2026-03-22 17:37:08.902799', '3500000.00', '2026-03-31', 'Hoc phi HK2 - 10A1 - Nguyen Van An', null, 'VNPAY', 'PENDING', 'A9214CA579164783', '1', '3');
INSERT INTO `tuition_payments` VALUES ('3', '2026-03-01 20:20:19.000000', '2026-03-22 18:09:42.329785', '500000.00', '2026-02-28', 'Phi hoat dong ngoai khoa - T2/2026', null, 'VNPAY', 'PENDING', '5BC96819FF1B48A8', '1', '3');
INSERT INTO `tuition_payments` VALUES ('4', '2026-03-22 18:19:04.000000', '2026-03-22 18:19:04.000000', '1500000.00', '2026-04-10', 'Hoc phi thang 4/2026', null, null, 'UNPAID', null, '1', '3');
INSERT INTO `tuition_payments` VALUES ('5', '2026-03-22 18:19:04.000000', '2026-03-22 18:19:04.000000', '3500000.00', '2026-04-25', 'Phu dao Toan, Ly, Hoa - T4', null, null, 'UNPAID', null, '1', '3');
INSERT INTO `tuition_payments` VALUES ('6', '2026-03-22 18:19:04.000000', '2026-03-22 18:19:04.000000', '800000.00', '2026-05-01', 'Phi tien an ban tru T5/2026', null, null, 'UNPAID', null, '1', '3');
INSERT INTO `tuition_payments` VALUES ('7', '2026-03-22 18:19:04.000000', '2026-03-22 18:19:04.000000', '1200000.00', '2026-05-15', 'Quy lop HK2 - Nguyen Van An', null, null, 'UNPAID', null, '1', '3');
INSERT INTO `tuition_payments` VALUES ('8', '2026-03-22 18:19:04.000000', '2026-03-22 18:19:04.000000', '4500000.00', '2026-06-05', 'Hoc phi On tap He thang 6', null, null, 'UNPAID', null, '1', '3');
INSERT INTO `tuition_payments` VALUES ('9', '2026-03-22 18:19:04.000000', '2026-03-22 18:19:04.000000', '500000.00', '2026-06-15', 'Dong phuc The duc cap moi', null, null, 'UNPAID', null, '1', '3');
INSERT INTO `tuition_payments` VALUES ('10', '2026-03-22 18:19:04.000000', '2026-03-22 18:19:04.000000', '3000000.00', '2026-07-01', 'Hoc phi thang 7/2026', null, null, 'UNPAID', null, '1', '3');
INSERT INTO `tuition_payments` VALUES ('11', '2026-03-22 18:19:04.000000', '2026-03-22 18:19:04.000000', '750000.00', '2026-07-20', 'Bao hiem y te nam hoc moi', null, null, 'UNPAID', null, '1', '3');
INSERT INTO `tuition_payments` VALUES ('12', '2026-03-22 18:19:04.000000', '2026-03-22 18:29:05.551627', '2300000.00', '2026-08-05', 'Tai lieu tham khao Toan, Ly, Hoa', '2026-03-22', 'VNPAY', 'PAID', '42EBEC9FF0B449F3', '1', '3');
INSERT INTO `tuition_payments` VALUES ('13', '2026-03-22 18:19:04.000000', '2026-03-22 18:20:18.491891', '100000.00', '2026-08-15', 'Le phi thi thu Dai hoc lan 1', '2026-03-22', 'VNPAY', 'PAID', '7C89292F4FE8464E', '1', '3');

-- ----------------------------
-- Table structure for `users`
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `active` bit(1) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `full_name` varchar(150) NOT NULL,
  `gender` enum('FEMALE','MALE','OTHER') DEFAULT NULL,
  `parent_code` varchar(50) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `student_code` varchar(50) DEFAULT NULL,
  `teacher_code` varchar(50) DEFAULT NULL,
  `two_factor_enabled` bit(1) NOT NULL,
  `two_factor_secret` varchar(100) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKr43af9ap4edm43mmtq01oddj6` (`username`),
  UNIQUE KEY `UK6dotkott2kjsp8vw4d0m25fb7` (`email`),
  UNIQUE KEY `UK5nfgvxelkdlxrrktoisbo7o1` (`parent_code`),
  UNIQUE KEY `UKcvkic8422oiw1di0trqm9fibr` (`student_code`),
  UNIQUE KEY `UKppvdcsb7oavmfcnqy28u0as9a` (`teacher_code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('1', '2026-03-21 20:20:19.000000', '2026-03-21 23:35:53.054070', '', '01 Trần Phú, Hà Nội', '1980-05-15', 'giapnhhe186581@fpt.edu.vn', 'Nguyễn Quản Trị', 'MALE', null, '$2a$10$If/0HKpH90IGwEBRVN3ZAuAF4FOMCFVkeOOEWB4BgnqCcOpIvdRH6', '0901000001', null, null, '', null, 'admin');
INSERT INTO `users` VALUES ('2', '2026-03-21 20:20:19.000000', '2026-03-22 16:57:44.486218', '', '12 Lê Lợi, Hà Nội', '1985-08-20', 'gdarmor2.0@gmail.com', 'Trần Thị Bích', 'FEMALE', null, '$2a$10$C1HgOlxBsN6M9ssH..5J7.3hzX7fONSkpUhanoNoBUcC/dlB5vB5W', '0901000002', null, 'GV001', '', 'CGZQ37D7F6PZWENQRWVQUREORZTIUX7R', 'teacher_bich');
INSERT INTO `users` VALUES ('3', '2026-03-21 20:20:19.000000', '2026-03-22 17:26:54.439370', '', '55 Nguyễn Huệ, Hà Nội', '2009-03-12', 'giapngo220@gmail.com', 'Nguyễn Văn An', 'MALE', null, '$2a$10$KmN1e8oWNtkyWgV7qEPthuR/0UCFgRNMLlznrWzFujUwBKt2aA45y', '0901000003', 'HS001', null, '', '76J3ZJJ5LTQXQDSRJNZ3GQZJBJGAPBTC', 'student_an');
INSERT INTO `users` VALUES ('4', '2026-03-21 20:20:19.000000', '2026-03-21 20:20:19.000000', '', '55 Nguyễn Huệ, Hà Nội', '1975-11-03', 'binh.nguyen@parent.vn', 'Nguyễn Văn Bình', 'MALE', 'PH001', '$2a$2a$10$phWo7FkOX7.EAghNBAjT5eoh8t9QMo9s94QTcQNof1YUoDXGSm5d6', '0901000004', null, null, '', null, 'parent_binh');

-- ----------------------------
-- Table structure for `user_roles`
-- ----------------------------
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles` (
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `FKh8ciramu9cc9q3qcqiv4ue8a6` (`role_id`),
  CONSTRAINT `FKh8ciramu9cc9q3qcqiv4ue8a6` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `FKhfh9dx7w3ubf1co1vdev94g3f` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of user_roles
-- ----------------------------
INSERT INTO `user_roles` VALUES ('1', '1');
INSERT INTO `user_roles` VALUES ('2', '2');
INSERT INTO `user_roles` VALUES ('3', '3');
INSERT INTO `user_roles` VALUES ('4', '4');
