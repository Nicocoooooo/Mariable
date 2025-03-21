import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/message_model.dart';
import '../../utils/logger.dart';
import '../models/data/conversation_model.dart';

class MessageService {
  final SupabaseClient _client = Supabase.instance.client;

  // Singleton pattern
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  // Récupérer les conversations d'un partenaire
  Future<List<ConversationModel>> getPartnerConversations(
      String partnerId) async {
    try {
      // Requête pour obtenir les conversations avec les détails des derniers messages
      final response = await _client.rpc(
        'get_partner_conversations',
        params: {'partner_id_param': partnerId},
      );

      return (response as List)
          .map((conv) => ConversationModel.fromMap(conv))
          .toList();
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des conversations', e);
      rethrow;
    }
  }

  // Récupérer les messages d'une conversation
  Future<List<MessageModel>> getConversationMessages(
      String conversationId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('date_envoi', ascending: true);

      return (response as List)
          .map((msg) => MessageModel.fromMap(msg))
          .toList();
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des messages', e);
      rethrow;
    }
  }

  // Envoyer un message
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String expediteurId,
    required String destinataireId,
    required String contenu,
    bool isAI = false,
  }) async {
    try {
      final response = await _client.from('messages').insert({
        'conversation_id': conversationId,
        'expediteur_id': expediteurId,
        'destinataire_id': destinataireId,
        'contenu': contenu,
        'lu': false,
        'message_ia': isAI,
        'date_envoi': DateTime.now().toIso8601String(),
      }).select();

      return MessageModel.fromMap(response[0]);
    } catch (e) {
      AppLogger.error('Erreur lors de l\'envoi du message', e);
      rethrow;
    }
  }

  // Marquer les messages comme lus
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await _client
          .from('messages')
          .update({'lu': true})
          .eq('conversation_id', conversationId)
          .eq('destinataire_id', userId)
          .eq('lu', false);
    } catch (e) {
      AppLogger.error('Erreur lors du marquage des messages comme lus', e);
      rethrow;
    }
  }

  // Créer une nouvelle conversation
  Future<String> createConversation({
    required String partnerId,
    required String clientId,
  }) async {
    try {
      // D'abord, vérifier si une conversation existe déjà entre ces utilisateurs
      final existing = await _client
          .from('conversations')
          .select('id')
          .eq('partner_id', partnerId)
          .eq('client_id', clientId)
          .maybeSingle();

      if (existing != null) {
        return existing['id'];
      }

      // Sinon, créer une nouvelle conversation
      final response = await _client.from('conversations').insert({
        'partner_id': partnerId,
        'client_id': clientId,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      return response[0]['id'];
    } catch (e) {
      AppLogger.error('Erreur lors de la création de la conversation', e);
      rethrow;
    }
  }

  // Obtenir le nombre de messages non lus
  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('destinataire_id', userId)
          .eq('lu', false);

      // Compter manuellement les éléments
      return (response as List).length;
    } catch (e) {
      AppLogger.error('Erreur lors du comptage des messages non lus', e);
      return 0;
    }
  }
}
