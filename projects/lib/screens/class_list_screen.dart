import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/class_models.dart';
import '../core/app_router.dart';
import '../services/api_service.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<ClassResponse> _classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() => _isLoading = true);
    try {
      final classes = await _apiService.getAllClasses();
      setState(() {
        _classes = classes;
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
        title: const Text('Lớp học', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _classes.isEmpty
          ? const Center(child: Text('Không có lớp học nào', style: TextStyle(color: AppColors.textLight)))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _classes.length,
        itemBuilder: (context, index) => _buildClassCard(_classes[index]),
      ),
    );
  }

  Widget _buildClassCard(ClassResponse c) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.classDetail, arguments: c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.class_outlined, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(
                    'Khối ${c.gradeLevel ?? "?"} - ${c.schoolYear ?? ""}',
                    style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                  if (c.homeroomTeacherName != null) ...[
                    const SizedBox(height: 4),
                    Text('GVCN: ${c.homeroomTeacherName}', style: const TextStyle(color: AppColors.textLight, fontSize: 13)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
