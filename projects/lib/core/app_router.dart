import 'package:flutter/material.dart';

import '../models/class_models.dart';
import '../screens/login_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/grades_screen.dart';
import '../screens/attendance_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/class_list_screen.dart';
import '../screens/class_detail_screen.dart';
import '../screens/leave_request_screen.dart';
import '../screens/tuition_screen.dart';
import '../screens/chat_list_screen.dart';
import '../screens/chat_detail_screen.dart';
import '../screens/change_password_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String schedule = '/schedule';
  static const String scores = '/scores';
  static const String attendance = '/attendance';
  static const String notifications = '/notifications';
  static const String classes = '/classes';
  static const String classDetail = '/class-detail';
  static const String leaveRequests = '/leave-requests';
  static const String tuition = '/tuition';
  static const String chatList = '/chat';
  static const String chatDetail = '/chat-detail';
  static const String changePassword = '/change-password';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.otp:
        final temporaryToken = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => OtpScreen(temporaryToken: temporaryToken));

      case AppRoutes.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.schedule:
        return MaterialPageRoute(builder: (_) => const ScheduleScreen());

      case AppRoutes.scores:
        return MaterialPageRoute(builder: (_) => const GradesScreen());

      case AppRoutes.attendance:
        return MaterialPageRoute(builder: (_) => const AttendanceScreen());

      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case AppRoutes.classes:
        return MaterialPageRoute(builder: (_) => const ClassListScreen());

      case AppRoutes.classDetail:
        final classData = settings.arguments as ClassResponse;
        return MaterialPageRoute(builder: (_) => ClassDetailScreen(classData: classData));

      case AppRoutes.leaveRequests:
        return MaterialPageRoute(builder: (_) => const LeaveRequestScreen());

      case AppRoutes.tuition:
        return MaterialPageRoute(builder: (_) => const TuitionScreen());

      case AppRoutes.chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case AppRoutes.chatDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => ChatDetailScreen(
          otherUserId: args['userId'] as int,
          otherUserName: args['name'] as String,
        ));

      case AppRoutes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}