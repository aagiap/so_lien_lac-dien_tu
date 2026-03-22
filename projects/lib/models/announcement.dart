class AnnouncementResponse {
  final int id;
  final int classId;
  final String className;
  final int teacherId;
  final String teacherName;
  final String title;
  final String content;
  final String? createdAt;

  AnnouncementResponse({
    required this.id,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherName,
    required this.title,
    required this.content,
    this.createdAt,
  });

  factory AnnouncementResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementResponse(
      id: json['id'] ?? 0,
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'],
    );
  }
}
