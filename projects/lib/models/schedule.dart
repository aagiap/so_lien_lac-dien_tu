class ScheduleResponse {
  final int id;
  final int classId;
  final String className;
  final int subjectId;
  final String subjectName;
  final int teacherId;
  final String teacherName;
  final String lessonDate;
  final String startTime;
  final String endTime;
  final String? room;
  final String? note;

  ScheduleResponse({
    required this.id,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.lessonDate,
    required this.startTime,
    required this.endTime,
    this.room,
    this.note,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      id: json['id'] ?? 0,
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',
      lessonDate: json['lessonDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      room: json['room'],
      note: json['note'],
    );
  }

  String get timeRange => '$startTime - $endTime';
}
