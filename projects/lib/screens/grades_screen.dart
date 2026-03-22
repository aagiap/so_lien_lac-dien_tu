import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/score.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  List<ScoreResponse> _scores = [];
  bool _isLoading = true;
  String _selectedSemester = 'SEMESTER_1';
  double _semesterGPA = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchScores();
  }

  Future<void> _fetchScores() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _sessionService.getUserId();
      if (userId == null) throw Exception('Không tìm thấy thông tin người dùng.');

      final scores = await _apiService.getStudentScores(
        studentId: userId,
        semester: _selectedSemester,
      );

      // Calculate GPA from all scores
      if (scores.isNotEmpty) {
        double total = 0;
        for (var s in scores) {
          total += s.scoreValue;
        }
        _semesterGPA = total / scores.length;
      } else {
        _semesterGPA = 0.0;
      }

      setState(() {
        _scores = scores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    }
  }

  // Group scores by subject
  Map<String, List<ScoreResponse>> get _groupedScores {
    final map = <String, List<ScoreResponse>>{};
    for (var score in _scores) {
      map.putIfAbsent(score.subjectName, () => []).add(score);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Bảng điểm', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Semester dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSemester,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'SEMESTER_1', child: Text('Học kỳ 1')),
                    DropdownMenuItem(value: 'SEMESTER_2', child: Text('Học kỳ 2')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedSemester = val);
                      _fetchScores();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // GPA Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Text(
                    _semesterGPA.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const Text(
                    'ĐIỂM TRUNG BÌNH HỌC KỲ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [_buildMiniBar(40), _buildMiniBar(55), _buildMiniBar(70), _buildMiniBar(90), _buildMiniBar(65), _buildMiniBar(80)],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subject list
            ..._groupedScores.entries.map((entry) => _buildSubjectTile(entry.key, entry.value)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBar(double height) {
    return Container(
      width: 12,
      height: height / 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: height > 80 ? AppColors.primary : AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSubjectTile(String subjectName, List<ScoreResponse> scores) {
    // Calculate average for this subject
    double avg = 0;
    if (scores.isNotEmpty) {
      avg = scores.fold(0.0, (sum, s) => sum + s.scoreValue) / scores.length;
    }

    // Find scores by type
    final regular = scores.where((s) => s.scoreType == 'REGULAR').toList();
    final midterm = scores.where((s) => s.scoreType == 'MIDTERM').toList();
    final finalExam = scores.where((s) => s.scoreType == 'FINAL').toList();

    String regularStr = regular.isNotEmpty ? regular.map((s) => s.scoreValue.toStringAsFixed(1)).join(', ') : '-';
    String midtermStr = midterm.isNotEmpty ? midterm.first.scoreValue.toStringAsFixed(1) : '-';
    String finalStr = finalExam.isNotEmpty ? finalExam.first.scoreValue.toStringAsFixed(1) : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getSubjectColor(subjectName).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getSubjectIcon(subjectName), color: _getSubjectColor(subjectName), size: 24),
          ),
          title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
          subtitle: Text(
            'GV: ${scores.isNotEmpty ? scores.first.teacherName : "---"}',
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: avg < 5.0 ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreDetail('TX', regularStr),
                  _buildScoreDetail('GK', midtermStr),
                  _buildScoreDetail('CK', finalStr),
                  _buildScoreDetail('TB', avg.toStringAsFixed(1), isBold: true, isLow: avg < 5.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDetail(String label, String value, {bool isBold = false, bool isLow = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isLow ? AppColors.error : (isBold ? AppColors.primary : AppColors.textDark),
          ),
        ),
      ],
    );
  }

  IconData _getSubjectIcon(String name) {
    if (name.contains('Toán')) return Icons.functions;
    if (name.contains('Ngữ văn') || name.contains('Văn')) return Icons.menu_book;
    if (name.contains('Tiếng Anh') || name.contains('Anh')) return Icons.language;
    if (name.contains('Vật lý') || name.contains('Lý')) return Icons.science_outlined;
    if (name.contains('Hóa học') || name.contains('Hóa')) return Icons.biotech_outlined;
    if (name.contains('Sinh')) return Icons.eco_outlined;
    if (name.contains('Sử')) return Icons.history_edu_outlined;
    if (name.contains('Địa')) return Icons.public_outlined;
    return Icons.subject;
  }

  Color _getSubjectColor(String name) {
    if (name.contains('Toán')) return Colors.orange;
    if (name.contains('Ngữ văn') || name.contains('Văn')) return Colors.deepOrangeAccent;
    if (name.contains('Tiếng Anh') || name.contains('Anh')) return Colors.blue;
    if (name.contains('Vật lý') || name.contains('Lý')) return Colors.purple;
    if (name.contains('Hóa học') || name.contains('Hóa')) return Colors.teal;
    if (name.contains('Sinh')) return Colors.green;
    if (name.contains('Sử')) return Colors.brown;
    if (name.contains('Địa')) return Colors.indigo;
    return AppColors.primary;
  }
}