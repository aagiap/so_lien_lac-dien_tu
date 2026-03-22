import 'package:flutter/material.dart';

import '../core/app_router.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  UserResponse? _user;
  bool _isLoading = true;
  bool _toggling2fa = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _apiService.getMe();
      await _sessionService.saveUserResponse(user);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _apiService.logout();
    } catch (_) {} // Logout may fail if token expired, but we still clear locally
    await _sessionService.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  Future<void> _handleEnable2fa() async {
    setState(() => _toggling2fa = true);
    try {
      final data = await _apiService.setup2fa();
      final otpAuthUrl = data['otpAuthUrl'] as String? ?? '';
      final secret = data['secret'] as String? ?? '';
      if (!mounted) return;

      // Show a dialog for the user to enter OTP after scanning the URL
      final otp = await _show2faSetupDialog(otpAuthUrl, secret);
      if (otp != null && otp.isNotEmpty) {
        await _apiService.enable2fa(otp: otp);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã bật 2FA thành công!'), backgroundColor: AppColors.success),
          );
        }
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _toggling2fa = false);
    }
  }

  Future<void> _handleDisable2fa() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tắt xác thực 2 yếu tố'),
        content: const Text('Bạn có chắc muốn tắt 2FA? Tài khoản sẽ kém bảo mật hơn.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tắt 2FA', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _toggling2fa = true);
    try {
      await _apiService.disable2fa();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tắt 2FA thành công'), backgroundColor: AppColors.success),
        );
      }
      await _loadProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _toggling2fa = false);
    }
  }

  Future<String?> _show2faSetupDialog(String otpAuthUrl, String secret) async {
    final otpController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Cấu hình 2FA', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('1. Mở ứng dụng Google Authenticator', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              const Text('2. Nhập mã sau vào ứng dụng:', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  secret,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('3. Nhập mã OTP 6 số từ ứng dụng:', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final val = otpController.text.trim();
              if (val.length == 6) Navigator.pop(ctx, val);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        foregroundColor: AppColors.textDark,
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _user == null
          ? const Center(child: Text('Không thể tải thông tin'))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Avatar
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?name=${_user!.fullName.replaceAll(' ', '+')}&background=F57C00&color=fff&size=256',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(_user!.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(_user!.roleDisplayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
            const SizedBox(height: 24),

            // Info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('THÔNG TIN CÁ NHÂN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                  const SizedBox(height: 16),
                  _buildInfoRow(icon: Icons.person_outline, title: 'Tên đăng nhập', value: _user!.username),
                  _buildInfoRow(icon: Icons.email_outlined, title: 'Email', value: _user!.email),
                  _buildInfoRow(icon: Icons.phone_outlined, title: 'Số điện thoại', value: _user!.phone ?? '---'),
                  if (_user!.gender != null)
                    _buildInfoRow(icon: Icons.wc_outlined, title: 'Giới tính', value: _genderDisplay(_user!.gender!)),
                  if (_user!.dateOfBirth != null)
                    _buildInfoRow(icon: Icons.calendar_today_outlined, title: 'Ngày sinh', value: _user!.dateOfBirth!),
                  if (_user!.address != null)
                    _buildInfoRow(icon: Icons.location_on_outlined, title: 'Địa chỉ', value: _user!.address!),
                  if (_user!.studentCode != null)
                    _buildInfoRow(icon: Icons.badge_outlined, title: 'Mã học sinh', value: _user!.studentCode!),
                  if (_user!.teacherCode != null)
                    _buildInfoRow(icon: Icons.badge_outlined, title: 'Mã giáo viên', value: _user!.teacherCode!),
                  if (_user!.parentCode != null)
                    _buildInfoRow(icon: Icons.badge_outlined, title: 'Mã phụ huynh', value: _user!.parentCode!, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2FA Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BẢO MẬT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _user!.twoFactorEnabled ? AppColors.success.withOpacity(0.1) : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.security,
                          color: _user!.twoFactorEnabled ? AppColors.success : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Xác thực 2 yếu tố (2FA)', style: TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              _user!.twoFactorEnabled ? 'Đang bật — tài khoản được bảo vệ' : 'Chưa bật — bật để bảo vệ tài khoản',
                              style: TextStyle(color: _user!.twoFactorEnabled ? AppColors.success : AppColors.textLight, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      _toggling2fa
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : Switch(
                              value: _user!.twoFactorEnabled,
                              activeColor: AppColors.success,
                              onChanged: (val) {
                                if (val) {
                                  _handleEnable2fa();
                                } else {
                                  _handleDisable2fa();
                                }
                              },
                            ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.changePassword),
              icon: const Icon(Icons.lock_reset, color: AppColors.primary),
              label: const Text('Đổi mật khẩu'),
            ),
            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Đăng xuất', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _genderDisplay(String gender) {
    switch (gender) {
      case 'MALE': return 'Nam';
      case 'FEMALE': return 'Nữ';
      default: return 'Khác';
    }
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String value, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}