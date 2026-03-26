import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();

  static const String _smsBridgeUrl = 'http://10.0.2.2:9099/inject';

  bool _submitting = false;
  bool _otpSent = false;
  String _phone = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await _apiService.forgotPasswordSms(phone: phone);
      if (!mounted) return;

      _phone = phone;
      final otp = (result['otp'] ?? '').toString();

      setState(() => _otpSent = true);
      String message = 'Yêu cầu OTP thành công. Vui lòng kiểm tra SMS.';

      if (otp.isNotEmpty) {
        final injected = await _injectSmsToEmulatorInbox(otp: otp);
        if (injected) {
          message = 'OTP đã được gửi vào app SMS của máy ảo.';
        } else {
          message = 'Đã tạo OTP nhưng chưa đẩy được vào SMS máy ảo. Hãy chạy SMS bridge trên máy tính.';
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<bool> _injectSmsToEmulatorInbox({required String otp}) async {
    try {
      final response = await http
          .post(
            Uri.parse(_smsBridgeUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sender': 'MyFSchool',
              'message': 'Your OTP is $otp. It expires in 300 seconds.',
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> && decoded['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await _apiService.resetPasswordSms(
        phone: _phone,
        otp: _otpController.text.trim(),
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: !_otpSent ? _buildPhoneStep() : _buildResetStep(),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
          child: const Icon(Icons.sms_outlined, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'Nhập số điện thoại của bạn',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hệ thống sẽ gửi OTP qua SMS nếu backend đã cấu hình cổng SMS',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textLight),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Số điện thoại',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submitting ? null : _sendOtp,
          child: _submitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Gửi mã OTP'),
        ),
      ],
    );
  }

  Widget _buildResetStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Đặt lại mật khẩu',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhập mã OTP từ thông báo SMS và mật khẩu mới',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Mã OTP (6 số)',
              prefixIcon: Icon(Icons.lock_clock_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập mã OTP';
              if (v.trim().length != 6) return 'Mã OTP phải gồm 6 số';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu mới',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu mới';
              if (v.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Xác nhận mật khẩu',
              prefixIcon: Icon(Icons.lock_reset_outlined),
            ),
            validator: (v) => v != _newPasswordController.text ? 'Mật khẩu xác nhận không khớp' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitting ? null : _resetPassword,
            child: _submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Xác nhận'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _otpSent = false),
            child: const Text('Gửi lại mã OTP', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
