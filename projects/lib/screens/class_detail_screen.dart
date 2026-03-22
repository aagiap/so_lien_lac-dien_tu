import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/class_models.dart';
import '../services/api_service.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassResponse classData;
  const ClassDetailScreen({super.key, required this.classData});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<ClassMemberResponse> _members = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await _apiService.getClassMembers(widget.classData.id);
      setState(() {
        _members = members;
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
    final students = _members.where((m) => m.memberRole == 'STUDENT').toList();
    final teachers = _members.where((m) => m.memberRole == 'TEACHER').toList();
    final parents = _members.where((m) => m.memberRole == 'PARENT').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: Text(widget.classData.name, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.class_outlined, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(widget.classData.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Khối ${widget.classData.gradeLevel ?? "?"} - ${widget.classData.schoolYear ?? ""}', style: const TextStyle(color: AppColors.textLight)),
                  if (widget.classData.homeroomTeacherName != null)
                    Text('GVCN: ${widget.classData.homeroomTeacherName}', style: const TextStyle(color: AppColors.textLight)),
                  Text('Sĩ số: ${students.length} học sinh', style: const TextStyle(color: AppColors.textLight)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (teachers.isNotEmpty) ...[
              _buildSectionTitle('Giáo viên'),
              ...teachers.map(_buildMemberCard),
              const SizedBox(height: 24),
            ],

            _buildSectionTitle('Danh sách học sinh'),
            ...students.map(_buildMemberCard),

            if (parents.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Phụ huynh'),
              ...parents.map(_buildMemberCard),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildMemberCard(ClassMemberResponse m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              'https://ui-avatars.com/api/?name=${m.fullName.replaceAll(' ', '+')}&background=F57C00&color=fff',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                Text(_roleDisplay(m.memberRole), style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          ),
        ],
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
