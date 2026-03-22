import 'user.dart';

class AuthResponse {
  final bool requiresOtp;
  final String? temporaryToken;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final UserResponse? user;

  AuthResponse({
    this.requiresOtp = false,
    this.temporaryToken,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      requiresOtp: json['requiresOtp'] ?? false,
      temporaryToken: json['temporaryToken'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      tokenType: json['tokenType'],
      user: json['user'] != null ? UserResponse.fromJson(json['user']) : null,
    );
  }
}

class TwoFactorSetupResponse {
  final String secret;
  final String qrCodeUri;

  TwoFactorSetupResponse({required this.secret, required this.qrCodeUri});

  factory TwoFactorSetupResponse.fromJson(Map<String, dynamic> json) {
    return TwoFactorSetupResponse(
      secret: json['secret'] ?? '',
      qrCodeUri: json['qrCodeUri'] ?? '',
    );
  }
}
