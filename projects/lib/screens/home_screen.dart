import 'package:flutter/material.dart';

import '../core/app_router.dart';
import '../core/constants.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../services/stomp_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _fullName = '';
  List<String> _roles = [];
  int? _classId;
  String _className = '';

  final SessionService _sessionService = SessionService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final fullName = await _sessionService.getFullName();
    final roles = await _sessionService.getRoles();
    final classId = await _sessionService.getClassId();
    final className = await _sessionService.getClassName();

    setState(() {
      _fullName = fullName ?? 'Người dùng';
      _roles = roles;
      _classId = classId;
      _className = className ?? '';
    });

    // If no classId saved yet, load classes to find user's class
    if (_classId == null) {
      await _loadClassInfo();
    }

    // Connect WebSocket for push notifications once user profile is loaded
    StompService().connect();
  }

  Future<void> _loadClassInfo() async {
    try {
      final classes = await _apiService.getAllClasses();
      if (classes.isNotEmpty) {
        final firstClass = classes.first;
        await _sessionService.saveClassInfo(firstClass.id, firstClass.name);
        setState(() {
          _classId = firstClass.id;
          _className = firstClass.name;
        });
      }
    } catch (_) {}
  }

  bool get _isStudent => _roles.contains('STUDENT');
  bool get _isTeacher => _roles.contains('TEACHER');
  bool get _isParent => _roles.contains('PARENT');

  String get _roleDisplay {
    if (_roles.contains('ADMIN')) return 'Quản trị viên';
    if (_isTeacher) return 'Giáo viên';
    if (_isParent) return 'Phụ huynh';
    return 'Học sinh';
  }

  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 1:
        Navigator.pushNamed(context, AppRoutes.schedule);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.scores);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.notifications);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
    // Reset index back to 0 when returning
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _selectedIndex = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24, right: 24, bottom: 30,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào, $_fullName',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _roleDisplay,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (_className.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _className,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        'https://ui-avatars.com/api/?name=${_fullName.replaceAll(' ', '+')}&background=0D8ABC&color=fff',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- GRID MENU ---
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(24.0),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: _buildMenuCards(),
            ),
          ),
        ],
      ),

      // --- BOTTOM NAV ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Lịch học'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border_outlined), activeIcon: Icon(Icons.star), label: 'Điểm'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), activeIcon: Icon(Icons.notifications), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }

  List<Widget> _buildMenuCards() {
    final List<Widget> cards = [];

    // Common for all roles
    cards.add(_buildMenuCard(icon: Icons.calendar_month_outlined, title: 'Thời khóa biểu', onTap: () => Navigator.pushNamed(context, AppRoutes.schedule)));
    cards.add(_buildMenuCard(icon: Icons.star_border_outlined, title: 'Bảng điểm', onTap: () => Navigator.pushNamed(context, AppRoutes.scores)));
    cards.add(_buildMenuCard(icon: Icons.how_to_reg_outlined, title: 'Điểm danh', onTap: () => Navigator.pushNamed(context, AppRoutes.attendance)));
    cards.add(_buildMenuCard(icon: Icons.notifications_none_outlined, title: 'Thông báo', onTap: () => Navigator.pushNamed(context, AppRoutes.notifications)));

    // Class management
    cards.add(_buildMenuCard(icon: Icons.class_outlined, title: 'Lớp học', onTap: () => Navigator.pushNamed(context, AppRoutes.classes)));

    // Leave requests
    cards.add(_buildMenuCard(icon: Icons.event_busy_outlined, title: 'Xin nghỉ', onTap: () => Navigator.pushNamed(context, AppRoutes.leaveRequests)));

    // Tuition (student/parent)
    if (_isStudent || _isParent) {
      cards.add(_buildMenuCard(icon: Icons.payment_outlined, title: 'Học phí', onTap: () => Navigator.pushNamed(context, AppRoutes.tuition)));
    }

    // Chat
    cards.add(_buildMenuCard(icon: Icons.chat_bubble_outline, title: 'Tin nhắn', onTap: () => Navigator.pushNamed(context, AppRoutes.chatList)));

    return cards;
  }

  Widget _buildMenuCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}