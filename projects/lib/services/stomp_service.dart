import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../core/constants.dart';
import 'session_service.dart';
import 'notification_service.dart';

typedef MessageCallback = void Function(Map<String, dynamic> data);

class StompService {
  static final StompService _instance = StompService._internal();
  factory StompService() => _instance;
  StompService._internal();

  StompClient? _stompClient;
  bool _isConnected = false;

  /// Listener that the active chat screen can set to receive messages live.
  MessageCallback? onChatMessageReceived;

  Future<void> connect() async {
    if (_isConnected || _stompClient != null) return;
    
    final token = await SessionService().getAccessToken();
    if (token == null) return;

    // Convert http://host:port/api to ws://host:port/ws/websocket for SockJS
    final wsUrl = AppConstants.baseUrl.replaceFirst('http', 'ws').replaceAll('/api', '/ws/websocket');
    
    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: onConnect,
        beforeConnect: () async {
          print('STOMP: Connecting to $wsUrl');
        },
        onWebSocketError: (dynamic error) => print('STOMP Error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient?.activate();
  }

  void onConnect(StompFrame frame) async {
    _isConnected = true;
    print('STOMP: Connected');
    
    final classId = await SessionService().getClassId();
    final notif = NotificationService();
    
    // Subscribe to personal chat messages
    _stompClient?.subscribe(
      destination: '/user/queue/messages',
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);

          // Forward to active chat screen listener (if set)
          onChatMessageReceived?.call(data);

          // Show push notification only when no listener is active (screen not open)
          if (onChatMessageReceived == null) {
            notif.showNotification('Tin nhắn từ ${data["senderName"]}', data["content"]);
          }
        }
      },
    );

    // Subscribe to class announcements
    if (classId != null) {
      _stompClient?.subscribe(
        destination: '/topic/announcements/$classId',
        callback: (frame) {
          if (frame.body != null) {
            final data = jsonDecode(frame.body!);
            notif.showNotification('📢 ${data["title"]}', data["content"]);
          }
        },
      );
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnected = false;
  }
}
