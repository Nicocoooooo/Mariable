import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/style_constants.dart';
import '../../models/data/conversation_model.dart';

class ConversationCard extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const ConversationCard({
    Key? key,
    required this.conversation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formatter pour la date
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    // Date formatée
    final String formattedDate = conversation.lastMessageTime != null
        ? formatter.format(conversation.lastMessageTime!)
        : formatter.format(conversation.createdAt);

    // Nom du client (ou 'Utilisateur' si non disponible)
    final String clientName = conversation.clientName ?? 'Utilisateur';

    return Card(
      elevation: conversation.hasUnread ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: conversation.hasUnread
            ? const BorderSide(
                color: PartnerAdminStyles.accentColor, width: 1.5)
            : BorderSide(color: Colors.grey.withAlpha(51)), // 20% opacité
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor:
                    PartnerAdminStyles.accentColor.withAlpha(51), // 20% opacité
                radius: 24,
                child: Text(
                  clientName.isNotEmpty ? clientName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: PartnerAdminStyles.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec nom et date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            clientName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: PartnerAdminStyles.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: conversation.hasUnread
                                ? PartnerAdminStyles.accentColor
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Dernier message
                    Text(
                      conversation.lastMessage ?? 'Nouvelle conversation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: conversation.hasUnread
                            ? FontWeight.w500
                            : FontWeight.normal,
                        color: conversation.hasUnread
                            ? PartnerAdminStyles.textColor
                            : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Indicateur de non-lu
              if (conversation.hasUnread)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: PartnerAdminStyles.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
