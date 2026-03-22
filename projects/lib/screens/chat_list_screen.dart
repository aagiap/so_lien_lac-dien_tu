import 'package:flutter/material.dart';

import '../core/app_router.dart';
import '../core/constants.dart';
import '../models/class_models.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  bool _isLoading = true;
  List<ClassMemberResponse> _contacts = [];
  int? _myUserId;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      _myUserId = await _sessionService.getUserId();
      final classId = await _sessionService.getClassId();

      if (classId == null) {
        final classes = await _apiService.getAllClasses();
        if (classes.isNotEmpty) {
          final members = await _apiService.getClassMembers(classes.first.id);
          setState(() {
            _contacts = members.where((m) => m.userId != _myUserId).toList();
            _isLoading = false;
          });
          return;
        }
        throw Exception('Không tìm thấy lớp.');
      }

      final members = await _apiService.getClassMembers(classId);
      setState(() {
        _contacts = members.where((m) => m.userId != _myUserId).toList();
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
        title: const Text('Tin nhắn', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _contacts.isEmpty
          ? const Center(child: Text('Không có liên hệ nào', style: TextStyle(color: AppColors.textLight)))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _contacts.length,
        itemBuilder: (context, index) => _buildContactCard(_contacts[index]),
      ),
    );
  }

  Widget _buildContactCard(ClassMemberResponse contact) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.chatDetail,
        arguments: {'userId': contact.userId, 'name': contact.fullName},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                'https://ui-avatars.com/api/?name=${contact.fullName.replaceAll(' ', '+')}&background=F57C00&color=fff',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(
                    _roleDisplay(contact.memberRole),
                    style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  String _roleDisplay(String role) {
    switch (role) {
      case 'STUDENT': return 'Học sinh';
      case 'TEACHER': return 'Giáo viên';
      case 'PARENT': return 'Phụ huynh';
      default: return role;
    }
  }
}
