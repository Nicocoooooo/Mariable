import 'package:flutter/foundation.dart';

class ChatMessage {
  final String id;
  final String content;
  final DateTime timestamp;
  final String senderId;
  final String senderName;
  final bool isFromCurrentUser;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.senderId,
    required this.senderName,
    required this.isFromCurrentUser,
    this.isRead = false,
  });
}

class ChatThread {
  final String id;
  final String providerId;
  final String providerName;
  final String providerType;
  final String providerImageUrl;
  final String lastMessageContent;
  final DateTime lastMessageTimestamp;
  final bool hasUnreadMessages;
  final List<ChatMessage> messages;

  ChatThread({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerType,
    this.providerImageUrl = '',
    required this.lastMessageContent,
    required this.lastMessageTimestamp,
    this.hasUnreadMessages = false,
    this.messages = const [],
  });
}