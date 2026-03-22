class ScoreResponse {
  final int id;
  final int studentId;
  final String studentName;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final String semester;
  final String scoreType;
  final double scoreValue;
  final String? comment;
  final String? createdAt;

  ScoreResponse({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.semester,
    required this.scoreType,
    required this.scoreValue,
    this.comment,
    this.createdAt,
  });

  factory ScoreResponse.fromJson(Map<String, dynamic> json) {
    return ScoreResponse(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',
      semester: json['semester'] ?? '',
      scoreType: json['scoreType'] ?? '',
      scoreValue: (json['scoreValue'] != null) ? double.tryParse(json['scoreValue'].toString()) ?? 0.0 : 0.0,
      comment: json['comment'],
      createdAt: json['createdAt'],
    );
  }

  String get scoreTypeDisplay {
    switch (scoreType) {
      case 'REGULAR': return 'Thường xuyên';
      case 'MIDTERM': return 'Giữa kỳ';
      case 'FINAL': return 'Cuối kỳ';
      default: return scoreType;
    }
  }
}
