import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  bool _isLoading = true;
  int? _classId;

  DateTime _weekStart = _getMonday(DateTime.now());
  List<ScheduleResponse> _allSchedules = [];
  List<DateTime> _uniqueDates = [];
  DateTime? _selectedDate;

  static DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    setState(() => _isLoading = true);
    try {
      _classId = await _sessionService.getClassId();

      if (_classId == null) {
        // Try to get class from API
        final classes = await _apiService.getAllClasses();
        if (classes.isNotEmpty) {
          _classId = classes.first.id;
          await _sessionService.saveClassInfo(classes.first.id, classes.first.name);
        }
      }

      if (_classId == null) {
        throw Exception("Không tìm thấy thông tin lớp học.");
      }

      final weekStartStr = DateFormat('yyyy-MM-dd').format(_weekStart);
      final schedules = await _apiService.getScheduleByWeek(classId: _classId!, weekStart: weekStartStr);

      // Group unique dates
      final Set<String> dateStrings = schedules.map((s) => s.lessonDate).toSet();
      _uniqueDates = dateStrings.map((ds) => DateTime.parse(ds)).toList()..sort();

      setState(() {
        _allSchedules = schedules;
        _selectedDate = _uniqueDates.isNotEmpty ? _uniqueDates.first : null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ScheduleResponse> _getSchedulesForSelectedDate() {
    if (_selectedDate == null) return [];
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    return _allSchedules.where((s) => s.lessonDate == dateString).toList();
  }

  void _changeWeek(int offset) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * offset));
    });
    _loadScheduleData();
  }

  @override
  Widget build(BuildContext context) {
    final schedulesToday = _getSchedulesForSelectedDate();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textDark,
        title: const Text('Thời khóa biểu', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekBanner(),
          if (_uniqueDates.isNotEmpty) _buildDateSelector(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              children: [
                Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 8),
                Text(
                  _selectedDate != null ? 'Ngày ${DateFormat('dd/MM').format(_selectedDate!)}' : 'Buổi học',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          Expanded(
            child: schedulesToday.isEmpty
                ? const Center(child: Text("Không có lịch học", style: TextStyle(color: AppColors.textLight)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: schedulesToday.length,
              itemBuilder: (context, index) => _buildScheduleCard(schedulesToday[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekBanner() {
    String startDate = DateFormat('dd/MM/yyyy').format(_weekStart);
    String endDate = DateFormat('dd/MM/yyyy').format(_weekStart.add(const Duration(days: 6)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.chevron_left, color: AppColors.primary), onPressed: () => _changeWeek(-1)),
            Expanded(
              child: Column(
                children: [
                  Text('$startDate - $endDate', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Năm học 2025-2026', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.chevron_right, color: AppColors.primary), onPressed: () => _changeWeek(1)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _uniqueDates.length,
        itemBuilder: (context, index) {
          final date = _uniqueDates[index];
          final isSelected = _selectedDate == date;
          final dayName = date.weekday == 7 ? 'CN' : 'T${date.weekday + 1}';
          final dayStr = DateFormat('dd/MM').format(date);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                border: isSelected ? null : Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayName, style: TextStyle(color: isSelected ? Colors.white : AppColors.textLight, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(dayStr, style: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleResponse item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.book_outlined, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                item.timeRange.replaceAll(' - ', '\n'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight, fontSize: 12, height: 1.3),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.subjectName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 8),
                  Text(item.room ?? 'Chưa xếp', style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textLight),
                  const SizedBox(width: 8),
                  Text(item.teacherName, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
                ]),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.notes_outlined, size: 16, color: AppColors.textLight),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.note!, style: const TextStyle(fontSize: 13, color: AppColors.textLight))),
                  ]),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(Icons.access_time_outlined, color: AppColors.primary.withOpacity(0.5), size: 28),
          ),
        ],
      ),
    );
  }
}