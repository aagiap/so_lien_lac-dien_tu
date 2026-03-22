import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../models/class_models.dart';
import '../models/schedule.dart';
import '../models/score.dart';
import '../models/attendance.dart';
import '../models/announcement.dart';
import '../models/leave_request.dart';
import '../models/tuition.dart';
import '../models/message.dart';
import '../models/subject.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // ─── Headers ───────────────────────────────────────────
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (requireAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ═══════════════════════════════════════════════════════
  //  AUTH
  // ═══════════════════════════════════════════════════════
  Future<AuthResponse> login({required String phone, required String password}) async {
    final data = await _post('/auth/login', body: {'phone': phone, 'password': password}, requireAuth: false);
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> verifyOtp({required String temporaryToken, required String otp}) async {
    final data = await _post('/auth/verify-otp', body: {'temporaryToken': temporaryToken, 'otp': otp}, requireAuth: false);
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    final data = await _post('/auth/refresh', body: {'refreshToken': refreshToken}, requireAuth: false);
    return AuthResponse.fromJson(data);
  }

  Future<void> forgotPassword({required String email}) async {
    await _post('/auth/forgot-password', body: {'email': email}, requireAuth: false);
  }

  Future<void> resetPassword({required String token, required String newPassword, required String confirmPassword}) async {
    await _post('/auth/reset-password', body: {'token': token, 'newPassword': newPassword, 'confirmPassword': confirmPassword}, requireAuth: false);
  }

  Future<void> logout() async {
    await _post('/auth/logout', body: {});
  }

  Future<Map<String, dynamic>> setup2fa() async {
    final data = await _post('/auth/setup-2fa', body: {});
    return Map<String, dynamic>.from(data);
  }

  Future<void> enable2fa({required String otp}) async {
    await _post('/auth/enable-2fa', body: {'otp': otp});
  }

  Future<void> disable2fa() async {
    await _post('/auth/disable-2fa', body: {});
  }

  // ═══════════════════════════════════════════════════════
  //  USER
  // ═══════════════════════════════════════════════════════
  Future<UserResponse> getMe() async {
    final data = await _get('/users/me');
    return UserResponse.fromJson(data);
  }

  Future<UserResponse> updateUser({required String fullName, String? phone, String? gender, String? dateOfBirth, String? address}) async {
    final body = <String, dynamic>{'fullName': fullName};
    if (phone != null) body['phone'] = phone;
    if (gender != null) body['gender'] = gender;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth;
    if (address != null) body['address'] = address;
    final data = await _put('/users/update', body: body);
    return UserResponse.fromJson(data);
  }

  Future<void> changePassword({required String oldPassword, required String newPassword, required String confirmPassword}) async {
    await _put('/users/change-password', body: {'oldPassword': oldPassword, 'newPassword': newPassword, 'confirmPassword': confirmPassword});
  }

  // ═══════════════════════════════════════════════════════
  //  CLASSES
  // ═══════════════════════════════════════════════════════
  Future<List<ClassResponse>> getAllClasses() async {
    final data = await _get('/classes');
    return (data as List).map((e) => ClassResponse.fromJson(e)).toList();
  }

  Future<List<ClassMemberResponse>> getClassMembers(int classId) async {
    final data = await _get('/classes/$classId/members');
    return (data as List).map((e) => ClassMemberResponse.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════
  //  SCHEDULE
  // ═══════════════════════════════════════════════════════
  Future<List<ScheduleResponse>> getScheduleByWeek({required int classId, required String weekStart}) async {
    final data = await _get('/schedule/week?classId=$classId&weekStart=$weekStart');
    return (data as List).map((e) => ScheduleResponse.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════
  //  SCORES
  // ═══════════════════════════════════════════════════════
  Future<List<ScoreResponse>> getStudentScores({required int studentId, required String semester}) async {
    final data = await _get('/scores/student?studentId=$studentId&semester=$semester');
    return (data as List).map((e) => ScoreResponse.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════
  //  ATTENDANCE
  // ═══════════════════════════════════════════════════════
  Future<List<AttendanceResponse>> getStudentAttendance({required int studentId}) async {
    final data = await _get('/attendance/student?studentId=$studentId');
    return (data as List).map((e) => AttendanceResponse.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════
  //  ANNOUNCEMENTS
  // ═══════════════════════════════════════════════════════
  Future<List<AnnouncementResponse>> getAnnouncementsByClass(int classId) async {
    final data = await _get('/announcements/class/$classId');
    return (data as List).map((e) => AnnouncementResponse.fromJson(e)).toList();
  }

  Future<AnnouncementResponse> createAnnouncement({required int classId, required String title, required String content}) async {
    final data = await _post('/announcements', body: {'classId': classId, 'title': title, 'content': content});
    return AnnouncementResponse.fromJson(data);
  }

  // ═══════════════════════════════════════════════════════
  //  LEAVE REQUESTS
  // ═══════════════════════════════════════════════════════
  Future<List<LeaveRequestResponse>> getMyLeaveRequests() async {
    final data = await _get('/leave-requests/my');
    return (data as List).map((x) => LeaveRequestResponse.fromJson(x)).toList();
  }

  Future<List<LeaveRequestResponse>> getAllLeaveRequests() async {
    final data = await _get('/leave-requests/all');
    return (data as List).map((x) => LeaveRequestResponse.fromJson(x)).toList();
  }

  Future<LeaveRequestResponse> createLeaveRequest({required int classId, required String fromDate, required String toDate, required String reason}) async {
    final data = await _post('/leave-requests', body: {'classId': classId, 'fromDate': fromDate, 'toDate': toDate, 'reason': reason});
    return LeaveRequestResponse.fromJson(data);
  }

  Future<LeaveRequestResponse> reviewLeaveRequest({required int requestId, required String status, String? responseNote}) async {
    final body = <String, dynamic>{'status': status};
    if (responseNote != null) body['responseNote'] = responseNote;
    final data = await _put('/leave-requests/$requestId/review', body: body);
    return LeaveRequestResponse.fromJson(data);
  }

  // ═══════════════════════════════════════════════════════
  //  TUITION PAYMENTS
  // ═══════════════════════════════════════════════════════

  // Ngân hàng	NCB
  // Số thẻ	9704198526191432198
  // Tên chủ thẻ NGUYEN VAN A
  // Ngày phát hành	07/15
  // Mật khẩu OTP	123456

  Future<List<TuitionPaymentResponse>> getTuitionByStudent({required int studentId}) async {
    final data = await _get('/tuition-payments/student?studentId=$studentId');
    return (data as List).map((e) => TuitionPaymentResponse.fromJson(e)).toList();
  }

  Future<VnPayUrlResponse> getVnPayUrl({required int paymentId}) async {
    final data = await _get('/tuition-payments/$paymentId/vnpay-url');
    return VnPayUrlResponse.fromJson(data);
  }

  // ═══════════════════════════════════════════════════════
  //  MESSAGES
  // ═══════════════════════════════════════════════════════
  Future<List<MessageResponse>> getConversation({required int otherUserId}) async {
    final data = await _get('/messages?otherUserId=$otherUserId');
    return (data as List).map((e) => MessageResponse.fromJson(e)).toList();
  }

  Future<MessageResponse> sendMessage({required int receiverId, required String content}) async {
    final data = await _post('/messages', body: {'receiverId': receiverId, 'content': content});
    return MessageResponse.fromJson(data);
  }

  // ═══════════════════════════════════════════════════════
  //  SUBJECTS
  // ═══════════════════════════════════════════════════════
  Future<List<SubjectResponse>> getAllSubjects() async {
    final data = await _get('/subjects');
    return (data as List).map((e) => SubjectResponse.fromJson(e)).toList();
  }

  // ═══════════════════════════════════════════════════════
  //  HTTP HELPERS
  // ═══════════════════════════════════════════════════════
  Future<dynamic> _get(String endpoint, {bool requireAuth = true}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final response = await _client.get(url, headers: headers).timeout(AppConstants.networkTimeout);
    return _parseResponse(response);
  }

  Future<dynamic> _post(String endpoint, {required Map<String, dynamic> body, bool requireAuth = true}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final response = await _client.post(url, headers: headers, body: jsonEncode(body)).timeout(AppConstants.networkTimeout);
    return _parseResponse(response);
  }

  Future<dynamic> _put(String endpoint, {required Map<String, dynamic> body, bool requireAuth = true}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(requireAuth: requireAuth);
    final response = await _client.put(url, headers: headers, body: jsonEncode(body)).timeout(AppConstants.networkTimeout);
    return _parseResponse(response);
  }

  dynamic _parseResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes).trim();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(body);
      // Backend wraps all responses in {success, message, data}
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    }

    String message = 'Đã xảy ra lỗi kết nối máy chủ (${response.statusCode}).';
    if (body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        } else {
          message = body;
        }
      } catch (_) {
        message = body;
      }
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      message = 'Phiên đăng nhập hết hạn hoặc bạn không có quyền truy cập.';
    }
    throw Exception(message);
  }
}