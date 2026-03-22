class AttendanceResponse {
  final int id;
  final int studentId;
  final String studentName;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final int? scheduleId;
  final String attendanceDate;
  final String status;
  final String? note;

  AttendanceResponse({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    this.scheduleId,
    required this.attendanceDate,
    required this.status,
    this.note,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',
      scheduleId: json['scheduleId'],
      attendanceDate: json['attendanceDate'] ?? '',
      status: json['status'] ?? '',
      note: json['note'],
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'PRESENT': return 'Có mặt';
      case 'ABSENT': return 'Vắng';
      case 'LATE': return 'Trễ';
      case 'EXCUSED': return 'Có phép';
      default: return status;
    }
  }

  bool get isPresent => status == 'PRESENT';
  bool get isAbsent => status == 'ABSENT';
  bool get isLate => status == 'LATE';
  bool get isExcused => status == 'EXCUSED';
}
