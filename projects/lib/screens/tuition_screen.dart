import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../models/tuition.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class TuitionScreen extends StatefulWidget {
  const TuitionScreen({super.key});

  @override
  State<TuitionScreen> createState() => _TuitionScreenState();
}

class _TuitionScreenState extends State<TuitionScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  bool _isLoading = true;
  List<TuitionPaymentResponse> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _sessionService.getUserId();
      if (userId == null) throw Exception('Không tìm thấy thông tin người dùng');

      final payments = await _apiService.getTuitionByStudent(studentId: userId);
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _payWithVnPay(int paymentId) async {
    try {
      final urlResponse = await _apiService.getVnPayUrl(paymentId: paymentId);
      final uri = Uri.parse(urlResponse.paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Không thể mở link thanh toán');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Học phí', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _payments.isEmpty
          ? const Center(child: Text('Không có dữ liệu học phí', style: TextStyle(color: AppColors.textLight)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _payments.length,
        itemBuilder: (context, index) => _buildPaymentCard(_payments[index]),
      ),
    );
  }

  Widget _buildPaymentCard(TuitionPaymentResponse p) {
    final amountStr = NumberFormat('#,###', 'vi_VN').format(p.amount);
    final statusColor = _statusColor(p.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(p.className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(p.statusDisplay, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Số tiền', '$amountStr₫', isBold: true),
          if (p.dueDate != null) _buildDetailRow('Hạn nộp', _fmt(p.dueDate!)),
          if (p.paidDate != null) _buildDetailRow('Ngày nộp', _fmt(p.paidDate!)),
          if (p.paymentMethod != null) _buildDetailRow('Hình thức', _methodDisplay(p.paymentMethod!)),
          if (p.orderInfo != null) _buildDetailRow('Nội dung', p.orderInfo!),

          if (!p.isPaid && p.status != 'PENDING') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _payWithVnPay(p.id),
                icon: const Icon(Icons.payment),
                label: const Text('Thanh toán VNPay'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isBold ? AppColors.primary : AppColors.textDark,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PAID': return AppColors.success;
      case 'OVERDUE': return AppColors.error;
      case 'PENDING': return AppColors.warning;
      default: return AppColors.textLight;
    }
  }

  String _methodDisplay(String method) {
    switch (method) {
      case 'CASH': return 'Tiền mặt';
      case 'BANK_TRANSFER': return 'Chuyển khoản';
      case 'VNPAY': return 'VNPay';
      default: return method;
    }
  }

  String _fmt(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }
}
