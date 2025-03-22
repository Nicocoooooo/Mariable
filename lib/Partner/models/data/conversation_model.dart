class ConversationModel {
  final String id;
  final String partnerId;
  final String clientId;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? clientName;
  final bool hasUnread;

  ConversationModel({
    required this.id,
    required this.partnerId,
    required this.clientId,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.clientName,
    this.hasUnread = false,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'],
      partnerId: map['partner_id'] ?? '',
      clientId: map['client_id'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      lastMessage: map['last_message'],
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.parse(map['last_message_time'])
          : null,
      clientName: map['client_name'],
      hasUnread: map['has_unread'] ?? false,
    );
  }
}
