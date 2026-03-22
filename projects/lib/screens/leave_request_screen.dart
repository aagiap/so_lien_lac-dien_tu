import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../models/leave_request.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  bool _isLoading = true;
  List<LeaveRequestResponse> _requests = [];
  bool _isTeacher = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      _isTeacher = await _sessionService.hasRole('TEACHER') || await _sessionService.hasRole('ADMIN');
      if (_isTeacher) {
        _requests = await _apiService.getAllLeaveRequests();
      } else {
        _requests = await _apiService.getMyLeaveRequests();
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _showCreateDialog() {
    final reasonController = TextEditingController();
    DateTime fromDate = DateTime.now();
    DateTime toDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tạo đơn xin nghỉ', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Từ ngày', style: TextStyle(fontSize: 14)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(fromDate)),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx, initialDate: fromDate,
                      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => fromDate = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Đến ngày', style: TextStyle(fontSize: 14)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(toDate)),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx, initialDate: toDate,
                      firstDate: fromDate, lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => toDate = picked);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Lý do'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) return;
                try {
                  final classId = await _sessionService.getClassId();
                  if (classId == null) throw Exception('Không tìm thấy lớp.');

                  await _apiService.createLeaveRequest(
                    classId: classId,
                    fromDate: DateFormat('yyyy-MM-dd').format(fromDate),
                    toDate: DateFormat('yyyy-MM-dd').format(toDate),
                    reason: reasonController.text.trim(),
                  );
                  if (mounted) Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
              child: const Text('Gửi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reviewRequest(LeaveRequestResponse request, String status) async {
    try {
      await _apiService.reviewLeaveRequest(requestId: request.id, status: status);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status == 'APPROVED' ? 'Đã duyệt đơn' : 'Đã từ chối đơn')),
        );
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
        title: const Text('Xin nghỉ học', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: !_isTeacher
          ? FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _requests.isEmpty
          ? const Center(child: Text('Chưa có đơn xin nghỉ nào', style: TextStyle(color: AppColors.textLight)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _requests.length,
        itemBuilder: (context, index) => _buildRequestCard(_requests[index]),
      ),
    );
  }

  Widget _buildRequestCard(LeaveRequestResponse r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(r.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
              ),
              _buildStatusBadge(r),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textLight),
              const SizedBox(width: 8),
              Text('${_fmt(r.fromDate)} → ${_fmt(r.toDate)}', style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.notes_outlined, size: 16, color: AppColors.textLight),
              const SizedBox(width: 8),
              Expanded(child: Text(r.reason, style: const TextStyle(fontSize: 13, color: AppColors.textDark))),
            ],
          ),
          if (r.responseNote != null && r.responseNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Ghi chú duyệt: ${r.responseNote}', style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontStyle: FontStyle.italic)),
          ],
          // Teacher review buttons
          if (_isTeacher && r.isPending) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _reviewRequest(r, 'REJECTED'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Từ chối'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _reviewRequest(r, 'APPROVED'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
                  child: const Text('Duyệt'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(LeaveRequestResponse r) {
    Color color;
    switch (r.status) {
      case 'APPROVED': color = AppColors.success; break;
      case 'REJECTED': color = AppColors.error; break;
      default: color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(r.statusDisplay, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  String _fmt(String dateStr) {
    try {
      return DateFormat('dd/MM').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }
}
