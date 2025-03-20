import 'package:equatable/equatable.dart';

/// Représente un message dans le système de messagerie
class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String expediteurId;
  final String destinataireId;
  final String contenu;
  final bool lu;
  final bool messageIA;
  final DateTime dateEnvoi;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.expediteurId,
    required this.destinataireId,
    required this.contenu,
    this.lu = false,
    this.messageIA = false,
    required this.dateEnvoi,
  });

  /// Crée un MessageModel à partir d'une Map (généralement depuis Supabase)
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      conversationId: map['conversation_id'],
      expediteurId: map['expediteur_id'],
      destinataireId: map['destinataire_id'],
      contenu: map['contenu'] ?? '',
      lu: map['lu'] ?? false,
      messageIA: map['message_ia'] ?? false,
      dateEnvoi: map['date_envoi'] != null
          ? DateTime.parse(map['date_envoi'])
          : DateTime.now(),
    );
  }

  /// Convertit en Map (généralement pour envoyer à Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'expediteur_id': expediteurId,
      'destinataire_id': destinataireId,
      'contenu': contenu,
      'lu': lu,
      'message_ia': messageIA,
      'date_envoi': dateEnvoi.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        expediteurId,
        destinataireId,
        contenu,
        lu,
        messageIA,
        dateEnvoi
      ];
}
