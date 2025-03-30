import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/message_model.dart';
import '../utils/logger.dart';

class MessagesService {
  final _supabase = Supabase.instance.client;

  // Récupérer toutes les conversations de l'utilisateur
  Future<List<ChatThread>> getThreads() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }

      // Récupérer les conversations où l'utilisateur est impliqué
      final response = await _supabase
          .from('conversations')
          .select('*, profiles!partner_id(*), messages!inner(*)')
          .or('client_id.eq.${user.id},partner_id.eq.${user.id}')
          .order('created_at', ascending: false);

      // Transformer les données en objets ChatThread
      List<ChatThread> threads = [];
      for (var conv in response) {
        // Déterminer si l'utilisateur est le client ou le partenaire
        bool isClient = conv['client_id'] == user.id;
        
        // Obtenir les informations du partenaire (l'autre personne)
        var partner = isClient ? conv['profiles'] : await _supabase
            .from('profiles')
            .select()
            .eq('id', conv['client_id'])
            .single();
        
        // Obtenir le dernier message
        var lastMessage = conv['messages'].isNotEmpty ? 
            conv['messages'].reduce((a, b) => 
              DateTime.parse(a['created_at']).isAfter(DateTime.parse(b['created_at'])) ? a : b) 
            : null;
        
        // Créer l'objet ChatThread
        threads.add(ChatThread(
          id: conv['id'],
          providerId: isClient ? conv['partner_id'] : conv['client_id'],
          providerName: isClient 
              ? '${partner['prenom'] ?? ''} ${partner['nom'] ?? ''}'.trim()
              : '${partner['prenom'] ?? ''} ${partner['nom'] ?? ''}'.trim(),
          providerType: isClient ? 'Prestataire' : 'Client',
          providerImageUrl: '', // Vous pourriez ajouter une URL d'image si disponible
          lastMessageContent: lastMessage != null ? lastMessage['contenu'] : 'Commencez une conversation',
          lastMessageTimestamp: lastMessage != null ? 
              DateTime.parse(lastMessage['created_at']) : DateTime.parse(conv['created_at']),
          hasUnreadMessages: lastMessage != null ? 
              (lastMessage['lu'] == false && lastMessage['expediteur_id'] != user.id) : false,
        ));
      }

      return threads;
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des conversations', e);
      // Retourner des données mocquées en cas d'erreur (pour le développement)
      return getMockThreads();
    }
  }

  // Récupérer les messages d'une conversation
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return [];
      }

      // Récupérer les messages de la conversation
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at');
      
      // Marquer les messages non lus comme lus si l'utilisateur n'est pas l'expéditeur
      await _supabase
          .from('messages')
          .update({'lu': true})
          .eq('conversation_id', conversationId)
          .eq('lu', false)
          .neq('expediteur_id', user.id);

      // Transformer les données en objets ChatMessage
      List<ChatMessage> messages = [];
      for (var msg in response) {
        messages.add(ChatMessage(
          id: msg['id'],
          content: msg['contenu'],
          timestamp: DateTime.parse(msg['created_at']),
          senderId: msg['expediteur_id'],
          senderName: msg['expediteur_id'] == user.id ? 'Vous' : 'Eux', // Vous pourriez récupérer le nom réel
          isFromCurrentUser: msg['expediteur_id'] == user.id,
          isRead: msg['lu'] ?? false,
        ));
      }

      return messages;
    } catch (e) {
      AppLogger.error('Erreur lors de la récupération des messages', e);
      // Retourner des données mocquées en cas d'erreur (pour le développement)
      return getMockMessages(conversationId);
    }
  }

  // Envoyer un message
  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      // Récupérer la conversation pour déterminer le destinataire
      final conversation = await _supabase
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .single();
      
      String destinataireId = conversation['client_id'] == user.id 
          ? conversation['partner_id'] 
          : conversation['client_id'];

      // Insérer le nouveau message
      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'expediteur_id': user.id,
        'destinataire_id': destinataireId,
        'contenu': content,
        'lu': false,
        'message_ia': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Mettre à jour la date de mise à jour de la conversation
      await _supabase
          .from('conversations')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors de l\'envoi du message', e);
      return false;
    }
  }

  // Créer une nouvelle conversation
  Future<String?> createConversation(String partnerId, String initialMessage) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      // Vérifier si une conversation existe déjà entre ces deux utilisateurs
      final existingConv = await _supabase
          .from('conversations')
          .select()
          .or('and(client_id.eq.${user.id},partner_id.eq.${partnerId}),and(client_id.eq.${partnerId},partner_id.eq.${user.id})')
          .maybeSingle();
      
      String conversationId;
      
      if (existingConv != null) {
        // Utiliser la conversation existante
        conversationId = existingConv['id'];
      } else {
        // Créer une nouvelle conversation
        final now = DateTime.now().toIso8601String();
        final newConv = await _supabase.from('conversations').insert({
          'client_id': user.id,
          'partner_id': partnerId,
          'created_at': now,
          'updated_at': now,
        }).select();
        
        conversationId = newConv[0]['id'];
      }
      
      // Envoyer le message initial
      if (initialMessage.isNotEmpty) {
        await sendMessage(conversationId, initialMessage);
      }
      
      return conversationId;
    } catch (e) {
      AppLogger.error('Erreur lors de la création de la conversation', e);
      return null;
    }
  }

  // Marquer tous les messages d'une conversation comme lus
  Future<bool> markAsRead(String conversationId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      await _supabase
          .from('messages')
          .update({'lu': true})
          .eq('conversation_id', conversationId)
          .eq('lu', false)
          .neq('expediteur_id', user.id);
      
      return true;
    } catch (e) {
      AppLogger.error('Erreur lors du marquage des messages comme lus', e);
      return false;
    }
  }

  // Méthodes avec données mock pour le développement
  
  List<ChatThread> getMockThreads() {
    final now = DateTime.now();
    
    return [
      ChatThread(
        id: 'thread_1',
        providerId: 'provider_1',
        providerName: 'Château des Fleurs',
        providerType: 'Lieu de réception',
        providerImageUrl: '',
        lastMessageContent: 'Bonjour, nous serions ravis de vous accueillir pour une visite de notre domaine.',
        lastMessageTimestamp: now.subtract(const Duration(hours: 2)),
        hasUnreadMessages: true,
      ),
      ChatThread(
        id: 'thread_2',
        providerId: 'provider_2',
        providerName: 'Maître Philippe',
        providerType: 'Traiteur',
        providerImageUrl: '',
        lastMessageContent: 'Nous avons bien reçu votre demande de devis, voici notre proposition...',
        lastMessageTimestamp: now.subtract(const Duration(days: 1)),
        hasUnreadMessages: false,
      ),
      ChatThread(
        id: 'thread_3',
        providerId: 'provider_3',
        providerName: 'Fleurs & Couleurs',
        providerType: 'Fleuriste',
        providerImageUrl: '',
        lastMessageContent: 'Merci pour votre visite aujourd\'hui ! N\'hésitez pas si vous avez d\'autres questions.',
        lastMessageTimestamp: now.subtract(const Duration(days: 3)),
        hasUnreadMessages: false,
      ),
    ];
  }

  List<ChatMessage> getMockMessages(String threadId) {
    final now = DateTime.now();
    
    switch (threadId) {
      case 'thread_1':
        return [
          ChatMessage(
            id: 'msg_1_1',
            content: 'Bonjour, je suis intéressé par votre lieu de réception pour notre mariage prévu le 15 juin 2023. Est-ce que cette date est disponible ?',
            timestamp: now.subtract(const Duration(days: 1, hours: 5)),
            senderId: 'current_user',
            senderName: 'Vous',
            isFromCurrentUser: true,
          ),
          ChatMessage(
            id: 'msg_1_2',
            content: 'Bonjour, merci pour votre intérêt ! Le 15 juin 2023 est actuellement disponible. Combien d\'invités prévoyez-vous pour votre réception ?',
            timestamp: now.subtract(const Duration(days: 1, hours: 3)),
            senderId: 'provider_1',
            senderName: 'Château des Fleurs',
            isFromCurrentUser: false,
          ),
          ChatMessage(
            id: 'msg_1_3',
            content: 'Nous prévoyons environ 120 personnes. Est-il possible de visiter votre domaine prochainement ?',
            timestamp: now.subtract(const Duration(hours: 4)),
            senderId: 'current_user',
            senderName: 'Vous',
            isFromCurrentUser: true,
          ),
          ChatMessage(
            id: 'msg_1_4',
            content: 'Bonjour, nous serions ravis de vous accueillir pour une visite de notre domaine. Nous sommes disponibles ce week-end ou en semaine après 18h. Quelle date vous conviendrait le mieux ?',
            timestamp: now.subtract(const Duration(hours: 2)),
            senderId: 'provider_1',
            senderName: 'Château des Fleurs',
            isFromCurrentUser: false,
            isRead: false,
          ),
        ];
      default:
        return [];
    }
  }
}