class ClassResponse {
  final int id;
  final String name;
  final int? gradeLevel;
  final String? schoolYear;
  final int? homeroomTeacherId;
  final String? homeroomTeacherName;

  ClassResponse({
    required this.id,
    required this.name,
    this.gradeLevel,
    this.schoolYear,
    this.homeroomTeacherId,
    this.homeroomTeacherName,
  });

  factory ClassResponse.fromJson(Map<String, dynamic> json) {
    return ClassResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      gradeLevel: json['gradeLevel'],
      schoolYear: json['schoolYear'],
      homeroomTeacherId: json['homeroomTeacherId'],
      homeroomTeacherName: json['homeroomTeacherName'],
    );
  }
}

class ClassMemberResponse {
  final int id;
  final int classId;
  final int userId;
  final String fullName;
  final String username;
  final String memberRole;
  final int? linkedStudentId;
  final String? linkedStudentName;

  ClassMemberResponse({
    required this.id,
    required this.classId,
    required this.userId,
    required this.fullName,
    required this.username,
    required this.memberRole,
    this.linkedStudentId,
    this.linkedStudentName,
  });

  factory ClassMemberResponse.fromJson(Map<String, dynamic> json) {
    return ClassMemberResponse(
      id: json['id'] ?? 0,
      classId: json['classId'] ?? 0,
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      memberRole: json['memberRole'] ?? '',
      linkedStudentId: json['linkedStudentId'],
      linkedStudentName: json['linkedStudentName'],
    );
  }
}
