class LeaveRequestResponse {
  final int id;
  final int studentId;
  final String studentName;
  final int classId;
  final String className;
  final String fromDate;
  final String toDate;
  final String reason;
  final String status;
  final int? reviewedById;
  final String? reviewedByName;
  final String? responseNote;
  final String? createdAt;
  final String? reviewedAt;

  LeaveRequestResponse({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    this.reviewedById,
    this.reviewedByName,
    this.responseNote,
    this.createdAt,
    this.reviewedAt,
  });

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      fromDate: json['fromDate'] ?? '',
      toDate: json['toDate'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      reviewedById: json['reviewedById'],
      reviewedByName: json['reviewedByName'],
      responseNote: json['responseNote'],
      createdAt: json['createdAt'],
      reviewedAt: json['reviewedAt'],
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'PENDING': return 'Chờ duyệt';
      case 'APPROVED': return 'Đã duyệt';
      case 'REJECTED': return 'Từ chối';
      default: return status;
    }
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
}
