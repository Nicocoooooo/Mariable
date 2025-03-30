import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/models/message_model.dart';
import '../services/messages_service.dart';
import 'chat_details_screen.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final MessagesService _messagesService = MessagesService();
  late List<ChatThread> _chatThreads;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatThreads();
  }

  Future<void> _loadChatThreads() async {
    // Simuler un chargement depuis une API
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _chatThreads = _messagesService.getMockThreads();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF524B46);
    const Color beige = Color(0xFFFFF3E4);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messagerie',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            )
          : _chatThreads.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadChatThreads,
                  color: accentColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _chatThreads.length,
                    itemBuilder: (context, index) {
                      final thread = _chatThreads[index];
                      return _buildChatThreadItem(thread, context);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Contactez des prestataires pour planifier votre mariage',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/prestataires');
              },
              icon: const Icon(Icons.search),
              label: const Text('Trouver des prestataires'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524B46),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildChatThreadItem(ChatThread thread, BuildContext context) {
  // Format the date
  final String formattedTime = _formatMessageDate(thread.lastMessageTimestamp);
  
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailsScreen(
              threadId: thread.id, 
              providerName: thread.providerName,
              providerId: thread.id, // Ajout du providerId manquant
            ),
          ),
        ).then((_) => _loadChatThreads()); // Recharger après retour
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider avatar with badge for unread messages
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage(
                      thread.providerImageUrl,
                    ),
                    onBackgroundImageError: (_, __) {
                      // Fallback if image fails to load
                    },
                    backgroundColor: const Color(0xFFF0F0F0),
                    child: thread.providerImageUrl.startsWith('assets/')
                        ? null
                        : Icon(
                            Icons.business,
                            color: Colors.grey[700],
                          ),
                  ),
                  if (thread.hasUnreadMessages)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Message content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            thread.providerName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: thread.hasUnreadMessages ? FontWeight.bold : FontWeight.w500,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: thread.hasUnreadMessages ? const Color(0xFF524B46) : Colors.grey[600],
                            fontWeight: thread.hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      thread.providerType,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      thread.lastMessageContent,
                      style: TextStyle(
                        fontSize: 14,
                        color: thread.hasUnreadMessages ? Colors.black87 : Colors.grey[700],
                        fontWeight: thread.hasUnreadMessages ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMessageDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      // Today: format as time
      return DateFormat.Hm().format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Hier';
    } else if (now.difference(timestamp).inDays < 7) {
      // This week: day name
      return DateFormat.E('fr_FR').format(timestamp);
    } else {
      // Older: format as date
      return DateFormat.MMMd('fr_FR').format(timestamp);
    }
  }
}