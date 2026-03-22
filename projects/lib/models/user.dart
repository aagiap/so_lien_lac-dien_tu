class UserResponse {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? address;
  final String? studentCode;
  final String? teacherCode;
  final String? parentCode;
  final bool twoFactorEnabled;
  final bool active;
  final Set<String> roles;

  UserResponse({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.studentCode,
    this.teacherCode,
    this.parentCode,
    this.twoFactorEnabled = false,
    this.active = true,
    required this.roles,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      address: json['address'],
      studentCode: json['studentCode'],
      teacherCode: json['teacherCode'],
      parentCode: json['parentCode'],
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      active: json['active'] ?? true,
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {},
    );
  }

  bool get isStudent => roles.contains('STUDENT');
  bool get isTeacher => roles.contains('TEACHER');
  bool get isParent => roles.contains('PARENT');
  bool get isAdmin => roles.contains('ADMIN');

  String get roleDisplayName {
    if (isAdmin) return 'Quản trị viên';
    if (isTeacher) return 'Giáo viên';
    if (isParent) return 'Phụ huynh';
    return 'Học sinh';
  }
}
