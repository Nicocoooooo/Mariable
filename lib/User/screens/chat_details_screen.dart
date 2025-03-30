import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/models/message_model.dart';
import '../services/messages_service.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String threadId;
  final String providerName;
  final String providerId;

  const ChatDetailsScreen({
    Key? key,
    required this.threadId,
    required this.providerName,
    required this.providerId,
  }) : super(key: key);

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final MessagesService _messagesService = MessagesService();
  late List<ChatMessage> _messages;
  bool _isLoading = true;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // ID de l'utilisateur courant (fictif pour le front)
  final String _currentUserId = 'current_user';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    // Simuler un chargement depuis une API
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _messages = _messagesService.getMockMessages(widget.threadId);
      _isLoading = false;
    });
    
    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      senderId: _currentUserId,
      senderName: 'Vous',
      isFromCurrentUser: true,
      isRead: false,
    );
    
    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF524B46);
    const Color beige = Color(0xFFFFF3E4);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.providerName,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Afficher infos du prestataire
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voir détails du prestataire'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            )
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyChat()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isUserMessage = message.isFromCurrentUser;
                            
                            // Check if we should show date header
                            final showDateHeader = index == 0 || 
                                !_isSameDay(_messages[index].timestamp, _messages[index - 1].timestamp);
                            
                            return Column(
                              children: [
                                if (showDateHeader)
                                  _buildDateHeader(message.timestamp),
                                _buildMessageBubble(message, isUserMessage),
                              ],
                            );
                          },
                        ),
                ),
                
                // Message input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Attachment button
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        color: accentColor,
                        onPressed: () {
                          // Fonctionnalité d'attachement de fichier
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité d\'attachement de fichier à venir'),
                            ),
                          );
                        },
                      ),
                      // Text field
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Écrivez votre message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: beige.withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      Container(
                        decoration: const BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          color: Colors.white,
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Pas encore de messages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Envoyez votre premier message à ${widget.providerName} pour commencer la conversation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate == today) {
      dateText = 'Aujourd\'hui';
    } else if (messageDate == yesterday) {
      dateText = 'Hier';
    } else {
      dateText = DateFormat.yMMMd('fr_FR').format(date);
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(
            child: Divider(thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: Divider(thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isUserMessage) {
    final time = DateFormat.Hm().format(message.timestamp);
    
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUserMessage 
              ? const Color(0xFF524B46) 
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUserMessage ? const Radius.circular(4) : null,
            bottomLeft: isUserMessage ? null : const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                color: isUserMessage ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUserMessage 
                        ? Colors.white.withOpacity(0.7) 
                        : Colors.grey[600],
                  ),
                ),
                if (isUserMessage) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead 
                        ? Colors.blue[300] 
                        : Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}