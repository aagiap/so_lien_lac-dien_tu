import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  bool _isLoading = true;
  List<AttendanceResponse> _allRecords = [];
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _sessionService.getUserId();
      if (userId == null) throw Exception('Không tìm thấy thông tin người dùng.');

      final records = await _apiService.getStudentAttendance(studentId: userId);
      setState(() {
        _allRecords = records;
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

  List<AttendanceResponse> get _filteredRecords {
    return _allRecords.where((r) {
      try {
        final date = DateTime.parse(r.attendanceDate);
        return date.month == _selectedMonth;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  int get _presentCount => _filteredRecords.where((r) => r.isPresent).length;
  int get _absentCount => _filteredRecords.where((r) => r.isAbsent).length;
  int get _lateCount => _filteredRecords.where((r) => r.isLate).length;
  int get _excusedCount => _filteredRecords.where((r) => r.isExcused).length;

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Điểm danh', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        children: [
          _buildSummaryCard(),
          _buildMonthSelector(),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('Không có dữ liệu điểm danh tháng này', style: TextStyle(color: AppColors.textLight)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: records.length,
              itemBuilder: (context, index) => _buildAttendanceItem(records[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Có mặt', _presentCount, AppColors.success),
          _buildStatItem('Vắng', _absentCount, AppColors.error),
          _buildStatItem('Trễ', _lateCount, AppColors.warning),
          _buildStatItem('Có phép', _excusedCount, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMonthSelector() {
    const months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final isSelected = month == _selectedMonth;

          return GestureDetector(
            onTap: () => setState(() => _selectedMonth = month),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                months[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceItem(AttendanceResponse r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _statusColor(r.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_statusIcon(r.status), color: _statusColor(r.status), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Text(
                  _formatDate(r.attendanceDate),
                  style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(r.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              r.statusDisplay,
              style: TextStyle(color: _statusColor(r.status), fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE dd/MM/yyyy', 'en').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PRESENT': return AppColors.success;
      case 'ABSENT': return AppColors.error;
      case 'LATE': return AppColors.warning;
      case 'EXCUSED': return Colors.blue;
      default: return AppColors.textLight;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'PRESENT': return Icons.check_circle_outline;
      case 'ABSENT': return Icons.cancel_outlined;
      case 'LATE': return Icons.timer_outlined;
      case 'EXCUSED': return Icons.verified_user_outlined;
      default: return Icons.help_outline;
    }
  }
}