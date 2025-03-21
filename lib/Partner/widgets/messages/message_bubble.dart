// lib/Partner/widgets/messages/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/message_model.dart';
import '../../../shared/constants/style_constants.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool showTime;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.showTime = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Couleurs pour les bulles de message
    final Color bubbleColor = isCurrentUser
        ? PartnerAdminStyles.accentColor
        : message.messageIA
            ? Colors.purple.shade100
            : Colors.grey.shade200;

    final Color textColor =
        isCurrentUser ? Colors.white : PartnerAdminStyles.textColor;

    // Formateur de date
    final formatter = DateFormat('HH:mm');
    final String formattedTime = formatter.format(message.dateEnvoi);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Bulle de message
          Container(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.only(bottom: 4),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge IA pour les messages automatiques
                if (message.messageIA && !isCurrentUser)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'IA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Contenu du message
                Text(
                  message.contenu,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Horodatage du message
          if (showTime)
            Padding(
              padding: isCurrentUser
                  ? const EdgeInsets.only(right: 8.0)
                  : const EdgeInsets.only(left: 8.0),
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
