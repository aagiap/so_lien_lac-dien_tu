class TuitionPaymentResponse {
  final int id;
  final int studentId;
  final String studentName;
  final int classId;
  final String className;
  final double amount;
  final String? dueDate;
  final String? paidDate;
  final String status;
  final String? paymentMethod;
  final String? vnpTxnRef;
  final String? orderInfo;

  TuitionPaymentResponse({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.amount,
    this.dueDate,
    this.paidDate,
    required this.status,
    this.paymentMethod,
    this.vnpTxnRef,
    this.orderInfo,
  });

  factory TuitionPaymentResponse.fromJson(Map<String, dynamic> json) {
    return TuitionPaymentResponse(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      amount: (json['amount'] != null) ? double.tryParse(json['amount'].toString()) ?? 0.0 : 0.0,
      dueDate: json['dueDate'],
      paidDate: json['paidDate'],
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'],
      vnpTxnRef: json['vnpTxnRef'],
      orderInfo: json['orderInfo'],
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'PAID': return 'Đã đóng';
      case 'UNPAID': return 'Chưa đóng';
      case 'PENDING': return 'Đang xử lý';
      case 'OVERDUE': return 'Quá hạn';
      default: return status;
    }
  }

  bool get isPaid => status == 'PAID';
  bool get isOverdue => status == 'OVERDUE';
}

class VnPayUrlResponse {
  final String paymentUrl;

  VnPayUrlResponse({required this.paymentUrl});

  factory VnPayUrlResponse.fromJson(Map<String, dynamic> json) {
    return VnPayUrlResponse(paymentUrl: json['paymentUrl'] ?? '');
  }
}
