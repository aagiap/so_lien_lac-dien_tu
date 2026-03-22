class MessageResponse {
  final int id;
  final int senderId;
  final String senderName;
  final int receiverId;
  final String receiverName;
  final String content;
  final bool read;
  final String? sentAt;

  MessageResponse({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    this.read = false,
    this.sentAt,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      id: json['id'] ?? 0,
      senderId: json['senderId'] ?? 0,
      senderName: json['senderName'] ?? '',
      receiverId: json['receiverId'] ?? 0,
      receiverName: json['receiverName'] ?? '',
      content: json['content'] ?? '',
      read: json['read'] ?? false,
      sentAt: json['sentAt'],
    );
  }
}
