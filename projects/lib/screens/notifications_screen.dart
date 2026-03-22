import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../models/announcement.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  bool _isLoading = true;
  List<AnnouncementResponse> _announcements = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final classId = await _sessionService.getClassId();
      if (classId == null) {
        // Try loading class first
        final classes = await _apiService.getAllClasses();
        if (classes.isNotEmpty) {
          await _sessionService.saveClassInfo(classes.first.id, classes.first.name);
          final announcements = await _apiService.getAnnouncementsByClass(classes.first.id);
          setState(() {
            _announcements = announcements;
            _isLoading = false;
          });
          return;
        }
        throw Exception('Không tìm thấy lớp học.');
      }

      final announcements = await _apiService.getAnnouncementsByClass(classId);
      setState(() {
        _announcements = announcements;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Thông báo', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _announcements.isEmpty
          ? const Center(child: Text('Không có thông báo nào', style: TextStyle(color: AppColors.textLight, fontSize: 16)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _announcements.length,
        itemBuilder: (context, index) => _buildAnnouncementCard(_announcements[index]),
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementResponse a) {
    String timeAgo = '';
    if (a.createdAt != null) {
      try {
        final dt = DateTime.parse(a.createdAt!);
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes} phút trước';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours} giờ trước';
        } else if (diff.inDays < 30) {
          timeAgo = '${diff.inDays} ngày trước';
        } else {
          timeAgo = DateFormat('dd/MM/yyyy').format(dt);
        }
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
          ),
          title: Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(a.teacherName, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(width: 8),
                  if (timeAgo.isNotEmpty)
                    Text('• $timeAgo', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(a.content, style: const TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}