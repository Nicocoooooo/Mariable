import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/constants/style_constants.dart';
import '../../shared/models/message_model.dart';
import '../../utils/logger.dart';
import '../services/message_service.dart';
import '../widgets/messages/message_bubble.dart';
import 'package:realtime_client/src/types.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;


class PartnerConversationScreen extends StatefulWidget {
  final String conversationId;
  final String clientId;
  final String clientName;
  final String partnerId;
  final String partnerName;
  final VoidCallback onConversationUpdated;

  const PartnerConversationScreen({
    Key? key,
    required this.conversationId,
    required this.clientId,
    required this.clientName,
    required this.partnerId,
    required this.partnerName,
    required this.onConversationUpdated,
  }) : super(key: key);

  @override
  State<PartnerConversationScreen> createState() =>
      _PartnerConversationScreenState();
}

class _PartnerConversationScreenState extends State<PartnerConversationScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;

  // Pour gérer la mise à jour en temps réel
  RealtimeChannel? _messagesChannel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesChannel?.unsubscribe();
    super.dispose();
  }

void _setupRealtimeSubscription() {
  try {
    // Obtenir le canal pour les messages
    _messagesChannel = Supabase.instance.client.channel('public:messages');
    
    // S'abonner aux changements avec la méthode onPostgresChanges
    _messagesChannel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (dynamic payload) {
        // Debug pour voir la structure exacte du payload
        print('Payload reçu: $payload');
        
        if (!mounted) return;
        
        try {
          // Essayer de récupérer les données du message
          final dynamic messageData = payload.new_record ?? payload.newRecord;
          
          if (messageData != null && 
              messageData['conversation_id'] == widget.conversationId) {
            // Créer un modèle de message à partir des données
            final message = MessageModel.fromMap(Map<String, dynamic>.from(messageData));
            
            setState(() {
              _messages.add(message);
            });
            
            _scrollToBottom();
            
            // Marquer comme lu si nécessaire
            if (message.destinataireId == widget.partnerId) {
              _messageService.markMessagesAsRead(
                conversationId: widget.conversationId,
                userId: widget.partnerId,
              );
            }
          }
        } catch (e) {
          print('Erreur lors du traitement du message: $e');
        }
      }
    ).subscribe();
  } catch (e) {
    print('Erreur lors de la configuration du canal temps réel: $e');
  }
}

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer les messages de la conversation
      final messages =
          await _messageService.getConversationMessages(widget.conversationId);

      // Marquer les messages comme lus
      await _messageService.markMessagesAsRead(
        conversationId: widget.conversationId,
        userId: widget.partnerId,
      );

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      // Défiler jusqu'au bas de la conversation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Notifier que la conversation a été mise à jour (pour actualiser la liste)
      widget.onConversationUpdated();
    } catch (e) {
      AppLogger.error('Erreur lors du chargement des messages', e);
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger les messages. Veuillez réessayer.';
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Envoyer le message
      await _messageService.sendMessage(
        conversationId: widget.conversationId,
        expediteurId: widget.partnerId,
        destinataireId: widget.clientId,
        contenu: messageText,
        isAI: false,
      );

      // Effacer le champ de texte
      _messageController.clear();

      // Simuler une réponse automatique pour la démonstration
      if (_messages.isEmpty) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          await _messageService.sendMessage(
            conversationId: widget.conversationId,
            expediteurId: widget.clientId,
            destinataireId: widget.partnerId,
            contenu:
                'Merci pour votre message ! Notre équipe vous répondra dans les plus brefs délais.',
            isAI: true,
          );
        }
      }
    } catch (e) {
      AppLogger.error('Erreur lors de l\'envoi du message', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi du message')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.clientName,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Corps de la conversation
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Chargement des messages...')
                : _errorMessage != null
                    ? ErrorView(
                        message: _errorMessage!,
                        actionLabel: 'Réessayer',
                        onAction: _loadMessages,
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mark_chat_unread_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Aucun message',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Démarrez la conversation en envoyant un message.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isCurrentUser =
                                  message.expediteurId == widget.partnerId;

                              // Déterminer si on doit afficher l'horodatage
                              final showTime = index == _messages.length - 1 ||
                                  _messages[index + 1].expediteurId !=
                                      message.expediteurId;

                              return MessageBubble(
                                message: message,
                                isCurrentUser: isCurrentUser,
                                showTime: showTime,
                              );
                            },
                          ),
          ),

          // Séparateur
          const Divider(height: 1),

          // Zone de saisie
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Champ de saisie
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),

                // Bouton d'envoi
                Container(
                  decoration: const BoxDecoration(
                    color: PartnerAdminStyles.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Espace pour le clavier virtuel
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
